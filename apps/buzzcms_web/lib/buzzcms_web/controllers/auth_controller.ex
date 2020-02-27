defmodule BuzzcmsWeb.AuthController do
  use BuzzcmsWeb, :controller
  plug Ueberauth

  alias Buzzcms.Auth
  alias BuzzcmsWeb.{Helpers, Jwt}
  alias Buzzcms.Schema.User

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case Auth.login(auth) do
      %User{} = user ->
        {:ok, jwt, _full_claims} = Jwt.sign(user)
        json(conn, %{access_token: jwt})

      {:error, reason} ->
        conn |> put_status(400) |> json(%{error: reason})
    end
  end

  def sign_up_with_email(conn, params) do
    result = Auth.sign_up_with_email(params)

    case result do
      %User{} = user ->
        {:ok, jwt, _full_claims} = Jwt.sign(user)
        json(conn, %{access_token: jwt})

      %Ecto.Changeset{} = changesets ->
        conn |> put_status(400) |> json(%{errors: Helpers.error_text(changesets)})
    end
  end

  def verify_token(conn, %{"token" => token, "user_id" => user_id}) do
    case Auth.verify_email(user_id, token) do
      :ok -> json(conn, %{ok: 1})
      {:error, reason} -> conn |> put_status(400) |> json(%{error: reason})
    end
  end

  def me(conn, _params) do
    payload = Guardian.Plug.current_resource(conn)
    json(conn, payload)
  end
end
