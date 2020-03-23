defmodule BuzzcmsWeb.EntryResolverTest do
  use BuzzcmsWeb.ConnCase
  import BuzzcmsWeb.ControllerTestUtils

  @create_mutation """
  mutation ($data: EntryInput!) {
    createEntry(input: { data: $data }) {
      result {
        node {
          id
          slug
          title
        }
      }
    }
  }
  """

  describe "entry mutation (with auth)" do
    test "mutation: create_entry", %{conn: conn} do
      conn =
        post(conn, "/graphql", %{
          "query" => @create_mutation,
          "variables" => %{
            data: %{title: "Hello", slug: "hello", entryTypeId: Base.encode64("EntryType:1")}
          }
        })

      assert %{
               "data" => %{
                 "createEntry" => %{
                   "result" => %{
                     "node" => %{"id" => _id, "slug" => "hello", "title" => "Hello"}
                   }
                 }
               }
             } = json_response(conn, 200)
    end

    setup %{conn: conn} do
      token = create_verified_user(conn, "admin")
      {:ok, conn: conn |> put_req_header("authorization", "bearer: " <> token)}
    end
  end

  describe "entry mutation (without auth)" do
    test "mutation: create_entry", %{conn: conn} do
      conn =
        post(conn, "/graphql", %{
          "query" => @create_mutation,
          "variables" => %{
            data: %{title: "Hello", slug: "hello", entryTypeId: Base.encode64("EntryType:1")}
          }
        })

      assert %{
               "data" => %{"createEntry" => nil},
               "errors" => [
                 %{
                   "locations" => [%{"column" => 3, "line" => 2}],
                   "message" => "Not authorized",
                   "path" => ["createEntry"]
                 }
               ]
             } = json_response(conn, 200)
    end
  end
end
