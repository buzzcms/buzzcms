defmodule BuzzcmsWeb.Image.Processor do
  require Logger
  alias Buzzcms.Repo
  alias Buzzcms.Schema.Image

  @type upload_image_result :: {:ok, any()} | {:error, String.t()}

  @doc """
  Save list of images to disk & insert to database
  """
  @spec save_images([Plug.Upload.t()], [{:keep_name, boolean()}, ...]) :: [upload_image_result]
  def save_images(
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

  @doc """
  Save 1 image to disk & insert to database
  """
  @spec save_image(Plug.Upload.t(), any()) :: upload_image_result
  def save_image(
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

  @doc """
  Get the bucket directory, fetch from environment variables
  """
  @spec bucket() :: String.t()
  def bucket do
    case System.fetch_env("MEDIA_BUCKET") do
      {:ok, dir} -> dir
      _ -> "buzzcms"
    end
  end

  @doc """
  Get the root media directory, fetch from environment variables
  """
  @spec root_dir() :: String.t()
  def root_dir do
    case System.fetch_env("MEDIA_DIR") do
      {:ok, dir} -> dir
      _ -> "./.tmp/media"
    end
  end
end
