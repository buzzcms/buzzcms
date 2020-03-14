defmodule BuzzcmsWeb.Cachex do
  import Plug.Conn

  def init(options) do
    # initialize options
    options
  end

  def call(conn, _opts) do
    id = conn.query_params["id"]
    variables = conn.query_params["variables"] || "{}"

    case id do
      nil ->
        conn

      id ->
        cache_id = get_cache_id(id, variables)

        case Cachex.get(:my_cache, cache_id) do
          {:ok, body} when body != nil ->
            IO.inspect("hit #{cache_id}")

            conn
            |> send_resp(200, body)
            |> halt()

          _ ->
            IO.inspect("miss #{cache_id}")

            conn
            |> Plug.Conn.register_before_send(fn %{resp_body: resp_body} = after_conn ->
              Cachex.put(:my_cache, cache_id, resp_body) |> IO.inspect()
              after_conn
            end)
        end
    end
  end

  defp get_cache_id(id, variables) do
    v =
      case variables do
        %{} = v -> v
        v -> Jason.decode!(v)
      end
      |> URI.encode_query()

    "#{id}:#{v}" |> IO.inspect(label: "document_id")
  end
end
