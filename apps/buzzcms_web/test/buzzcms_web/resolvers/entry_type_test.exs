defmodule BuzzcmsWeb.EntryTypeResolverTest do
  use BuzzcmsWeb.ConnCase
  import BuzzcmsWeb.ControllerTestUtils

  @query """
  {
    entry_types(first: 10) {
      count
      edges {
        node {
          id
          code
          display_name
        }
      }
    }
  }
  """
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

  describe "entry type query" do
    test "query: entry_types", %{conn: conn} do
      conn =
        post(conn, "/graphql", %{
          "query" => @query,
          "variables" => %{}
        })

      assert %{
               "data" => %{"entry_types" => %{"count" => 1, "edges" => _edges}}
             } = json_response(conn, 200)
    end
  end

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
      conn =
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
