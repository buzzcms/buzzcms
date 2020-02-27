defmodule BuzzcmsWeb.ControllerTestUtils do
  use Phoenix.ConnTest
  import Ecto.Query
  import Buzzcms.Factory

  alias Buzzcms.Repo
  alias Buzzcms.Schema.{EmailTemplate, Token, User}

  @endpoint BuzzcmsWeb.Endpoint

  def sign_up_with_email(conn, user_payload) do
    post(conn, "/auth/register", user_payload)
  end

  def decode_token(conn) do
    %{"access_token" => token} = conn |> json_response(200)
    {:ok, %{"sub" => user_id}} = BuzzcmsWeb.Auth.Guardian.decode_and_verify(token)
    %{user_id: user_id, token: token}
  end

  def verify_user_email(conn, user_id, token) do
    post(conn, "/auth/verify", %{user_id: user_id, token: token})
  end

  def check_user_is_verified(user_id) do
    %{is_verified: is_verified} = Repo.get!(User, user_id, select: [:is_verified])
    is_verified
  end

  def get_verify_token(user_id) do
    %{token: token} = Repo.one(from t in Token, where: t.user_id == ^user_id)
    token
  end

  def make_token_expired(token) do
    from(t in Token, where: t.token == ^token, update: [set: [expired_at: fragment("now()")]])
    |> Repo.update_all([])
  end

  def sign_in_with_email(_email, _password, _system_project_id) do
  end

  def get_email_template_types() do
    Repo.all(from t in EmailTemplate, select: t.type)
  end

  def create_email_sender() do
    %{id: email_sender_id} = insert(:email_sender, %{is_verified: true})

    from(t in EmailTemplate,
      update: [set: [email_sender_id: ^email_sender_id]]
    )
    |> Repo.update_all([])
  end
end
