defmodule BuzzcmsWeb.EntryResolverTest do
  use BuzzcmsWeb.ConnCase

  @query """
  {
    entries(first: 10) {
      count
      edges {
        node {
          id
          slug
          title
        }
      }
    }
  }
  """
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

  test "query: entries", %{conn: conn} do
    conn =
      post(conn, "/graphql", %{
        "query" => @query,
        "variables" => %{}
      })

    assert %{"data" => %{"entries" => %{"count" => 0, "edges" => []}}} = json_response(conn, 200)
  end

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
end
