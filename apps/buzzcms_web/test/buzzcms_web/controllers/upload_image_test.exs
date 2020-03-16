defmodule BuzzcmsWeb.UploadImageTest do
  use BuzzcmsWeb.ConnCase

  describe "Image controller" do
    test "not exists image", %{conn: conn} do
      files = [
        %Plug.Upload{path: "test/fixtures/images/not-found.png", filename: "not-found.png"}
      ]

      conn = post(conn, "/images/upload", %{:files => files})

      assert %{
               "error" => [
                 %{
                   "filename" => "not-found.png",
                   "reason" => "Unknown error"
                 }
               ]
             } = json_response(conn, 200)
    end

    test "upload jpg", %{conn: conn} do
      files = [%Plug.Upload{path: "test/fixtures/images/sample.jpg", filename: "sample.jpg"}]

      conn = post(conn, "/images/upload", %{:files => files})

      assert %{
               "ok" => [
                 %{
                   "ext" => ".jpg",
                   "height" => "300",
                   "mime" => "image/jpeg",
                   "name" => "sample.jpg",
                   "width" => "300"
                 }
               ]
             } = json_response(conn, 200)
    end

    test "upload png", %{conn: conn} do
      files = [%Plug.Upload{path: "test/fixtures/images/sample.png", filename: "sample.png"}]

      conn = post(conn, "/images/upload", %{:files => files})

      assert %{
               "ok" => [
                 %{
                   "ext" => ".png",
                   "height" => "300",
                   "mime" => "image/png",
                   "name" => "sample.png",
                   "width" => "300"
                 }
               ]
             } = json_response(conn, 200)
    end

    test "svg", %{conn: conn} do
      files = [
        %Plug.Upload{
          path: "test/fixtures/images/sample.svg",
          filename: "sample.svg",
          content_type: "image/svg+xml"
        }
      ]

      conn = post(conn, "/images/upload", %{:files => files})

      assert %{
               "ok" => [
                 %{
                   # Id must be preserve when set keepFilename = true
                   "ext" => ".svg",
                   "mime" => "image/svg+xml",
                   "name" => "sample.svg"
                 }
               ]
             } = json_response(conn, 200)
    end

    test "use keepFilename", %{conn: conn} do
      files = [%Plug.Upload{path: "test/fixtures/images/sample.png", filename: "sample.png"}]

      conn = post(conn, "/images/upload", %{:files => files, "keepFilename" => true})

      assert %{
               "ok" => [
                 %{
                   # Id must be preserve when set keepFilename = true
                   "id" => "sample.png",
                   "ext" => ".png",
                   "height" => "300",
                   "mime" => "image/png",
                   "name" => "sample.png",
                   "width" => "300"
                 }
               ]
             } = json_response(conn, 200)
    end
  end
end
