defmodule BuzzcmsWeb.Context do
  @behaviour Plug

  alias BuzzcmsWeb.Auth.Guardian

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  @doc """
  Return the current user context based on the authorization header
  """
  def build_context(conn) do
    case Guardian.Plug.current_resource(conn) do
      %{"sub" => user_id, "role" => role} ->
        %{
          user_id: user_id,
          role: role
        }

      _ ->
        %{}
    end
  end
end
