defmodule BuzzcmsWeb.ImageController do
  require Logger
  use BuzzcmsWeb, :controller

  import BuzzcmsWeb.ImageParser
  alias Buzzcms.Repo
  alias Buzzcms.Schema.Image

  def view(conn, %{"id" => id}) do
    id = get_id(id)

    file_path =
      Path.join([
        root_dir(),
        bucket(),
        "origin",
        id
      ])

    conn
    |> put_resp_content_type(MIME.from_path(file_path))
    |> send_file(200, file_path)
  end

  def transform(conn, %{
        "id" => id,
        "transform" => unordered_transform
      }) do
    id = get_id(id)
    content_type = MIME.from_path(id)

    case content_type do
      t when t in ["image/svg+xml", "image/gif"] ->
        file_path =
          Path.join([
            root_dir(),
            bucket(),
            "origin",
            id
          ])

        conn
        |> put_resp_content_type(MIME.from_path(file_path))
        |> send_file(200, file_path)

      _ ->
        map = to_map(unordered_transform)

        cache_path =
          Path.join([
            root_dir(),
            bucket(),
            "transform",
            to_transform(map),
            id
          ])

        case File.exists?(cache_path) do
          true ->
            conn |> send_file(200, cache_path)

          false ->
            request_url = to_request_url(%{map: map, id: id, bucket: bucket()})

            %{body: body, status_code: status_code} = HTTPoison.get!(request_url)

            case status_code do
              200 ->
                File.mkdir_p!(Path.dirname(cache_path))
                File.write!(cache_path, body)

                conn
                |> put_resp_content_type(MIME.from_path(cache_path))
                |> send_resp(200, body)

              _ ->
                conn
                |> send_resp(400, body)
            end
        end
    end
  end

  def upload(conn, %{"files" => files} = args) do
    save_images(
      files,
      keep_name: Map.has_key?(args, "keepFilename")
    )

    conn |> json(%{ok: 1})
  end

  defp get_id(id) do
    case Base.decode64(id) do
      {:ok, "Image:" <> result} -> result
      _ -> id
    end
  end

  defp save_images(
         files,
         keep_name: keep_name
       ) do
    Path.join([
      root_dir(),
      bucket(),
      "origin"
    ])
    |> File.mkdir_p!()

    files
    |> Enum.map(fn file ->
      save_image(
        file,
        keep_name: keep_name
      )
    end)
  end

  defp save_image(
         %{path: path, filename: filename, content_type: content_type},
         keep_name: keep_name
       ) do
    with ext <- Path.extname(filename),
         name <- Path.basename(filename),
         {:ok, buffer} <- File.read(path),
         {:ok, %{size: size}} <- File.stat(path),
         info <- ExImageInfo.info(buffer),
         id <- if(keep_name, do: name, else: "#{Nanoid.generate(12)}#{ext}"),
         dest_file <-
           Path.join([
             root_dir(),
             bucket(),
             "origin",
             id
           ]),
         :ok <- File.cp(path, dest_file) do
      base = %{
        id: id,
        name: name,
        ext: ext,
        size: size,
        status: "uploaded"
      }

      %Image{}
      |> Image.changeset(
        case info do
          {mime, width, height, _} ->
            base
            |> Map.merge(%{
              mime: mime,
              width: width,
              height: height
            })

          nil ->
            base |> Map.merge(%{mime: content_type})
        end
      )
      |> Repo.insert()
    else
      error ->
        inspect(error) |> Logger.debug()
        {:error, "Invalid image"}
    end
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
