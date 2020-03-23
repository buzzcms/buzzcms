defmodule BuzzcmsWeb.EntryTypeResolverTest do
  use BuzzcmsWeb.ConnCase
  import BuzzcmsWeb.ControllerTestUtils

  @create_mutation """
  mutation ($data: EntryTypeInput!) {
    createEntryType(input: { data: $data }) {
      result {
        node {
          id
          code
          display_name
        }
      }
    }
  }
  """

  describe "entry type mutation (with auth)" do
    test "mutation: create_entry_type", %{conn: conn} do
      conn =
        post(conn, "/graphql", %{
          "query" => @create_mutation,
          "variables" => %{
            data: %{code: "product", display_name: "Product"}
          }
        })

      assert %{
               "data" => %{
                 "createEntryType" => %{
                   "result" => %{
                     "node" => %{
                       "code" => "product",
                       "display_name" => "Product"
                     }
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

  describe "entry type mutation (without auth)" do
    test "mutation: create_entry_type", %{conn: conn} do
      post(conn, "/graphql", %{
        "query" => @create_mutation,
        "variables" => %{
          data: %{code: "product", display_name: "Product"}
        }
      })

      assert %{
        "data" => %{"createEntryType" => nil},
        "errors" => [
          %{
            "locations" => [%{"column" => 3, "line" => 2}],
            "message" => "Not authorized",
            "path" => ["createEntryType"]
          }
        ]
      }
    end
  end
end
