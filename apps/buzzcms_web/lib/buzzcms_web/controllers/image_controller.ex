defmodule BuzzcmsWeb.ImageController do
  require Logger
  use BuzzcmsWeb, :controller

  import BuzzcmsWeb.Image.Processor
  import BuzzcmsWeb.Image.Parser

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
    result =
      save_images(
        files,
        keep_name: Map.has_key?(args, "keepFilename")
      )
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
      |> Enum.map(fn {key, value} -> {Kernel.to_string(key), value} end)
      |> Enum.into(%{})

    conn |> json(result)
  end

  @spec get_id(id: String.t()) :: String.t()
  defp get_id(id) do
    case Base.decode64(id) do
      {:ok, "Image:" <> result} -> result
      _ -> id
    end
  end
end
