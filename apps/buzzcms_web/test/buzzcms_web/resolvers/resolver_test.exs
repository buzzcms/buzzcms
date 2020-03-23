files = Path.wildcard("test/support/graphql/*/*")

defmodule BuzzcmsWeb.ResolverTest do
  use BuzzcmsWeb.ConnCase

  describe "resolver test" do
    Enum.each(files, fn file ->
      test "#{file |> String.replace("test/support/graphql/", "")}", %{conn: conn} do
        %{query: query, result: result} = read_fixture(unquote(file))

        conn =
          post(conn, "/graphql", %{
            "query" => query
          })

        assert result == json_response(conn, 200)
      end
    end)
  end

  defp read_fixture(file) when is_bitstring(file) do
    with {:ok, query} <- File.read(Path.join(file, "query.gql")),
         {:ok, result_json} <- File.read(Path.join(file, "result.json")),
         {:ok, result} <- Jason.decode(result_json) do
      %{query: query, result: result}
    end
  end
end
