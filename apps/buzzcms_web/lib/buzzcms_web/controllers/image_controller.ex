defmodule BuzzcmsWeb.ImageController do
  use BuzzcmsWeb, :controller

  import BuzzcmsWeb.ImageParser
  alias Buzzcms.Repo
  alias Buzzcms.Schema.Image

  def view(conn, %{"id" => id}) do
    id = get_id(id)
    file_path = Path.join([dir(), "origin", id])
    conn |> send_file(200, file_path)
  end

  def transform(conn, %{
        "id" => id,
        "transform" => unordered_transform
      }) do
    id = get_id(id)
    map = to_map(unordered_transform)
    cache_path = Path.join([dir(), "transform", to_transform(map), id])

    case File.exists?(cache_path) do
      true ->
        conn |> send_file(200, cache_path)

      false ->
        request_url = to_request_url(%{map: map, id: id, bucket: bucket()})
        %{body: body} = HTTPoison.get!(request_url)
        # IO.inspect(request_url)
        File.mkdir_p!(Path.dirname(cache_path))
        File.write!(cache_path, body)
        conn |> put_resp_content_type("image/png") |> send_resp(200, body)
    end
  end

  def upload(conn, %{"files" => files}) do
    save_images(files)
    conn |> json(%{ok: 1})
  end

  defp get_id(id) do
    case Base.decode64(id) do
      {:ok, "Image:" <> result} -> result
      _ -> id
    end
  end

  defp save_images(files) do
    Path.join([dir(), "origin"]) |> File.mkdir_p!()

    files
    |> Enum.map(fn file ->
      save_image(file)
    end)
  end

  defp save_image(%{path: path, filename: filename}) do
    with ext <- Path.extname(filename),
         name <- Path.basename(filename),
         {:ok, buffer} <- File.read(path),
         {:ok, %{size: size}} <- File.stat(path),
         {mime, width, height, _} <- ExImageInfo.info(buffer),
         id <- Nanoid.generate(12),
         dest_file <- Path.join([dir(), "origin", id]),
         :ok <- File.cp(path, dest_file) do
      %Image{}
      |> Image.changeset(%{
        id: id,
        name: name,
        ext: ext,
        mime: mime,
        width: width,
        height: height,
        size: size,
        status: "uploaded"
      })
      |> Repo.insert()
    else
      error ->
        # IO.inspect(error)
        {:error, "Invalid image"}
    end
  end

  defp dir do
    Path.join(root_dir(), bucket())
  end

  defp root_dir do
    case System.fetch_env("MEDIA_DIR") do
      {:ok, dir} -> dir
      _ -> "./.tmp/media"
    end
  end

  defp bucket do
    case System.fetch_env("MEDIA_BUCKET") do
      {:ok, dir} -> dir
      _ -> "buzzcms"
    end
  end
end
