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

  @spec sign_in_with_email(Plug.Conn.t(), any()) :: Guardian.Token.token()
  def sign_in_with_email(conn, user) do
    %{"access_token" => token} = post(conn, "/auth/identity/callback", user) |> json_response(200)

    token
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

  @doc """
  Create a verified user with a specific role
  """
  @spec create_verified_user(Plug.Conn.t(), String.t()) :: Guardian.Token.token()
  def create_verified_user(conn, role) do
    user_payload = build(:email_signup_payload)

    # Create user
    %{user_id: user_id} =
      conn
      |> sign_up_with_email(user_payload)
      |> decode_token()

    # Verify created user
    verify_user_email(conn, user_id, get_verify_token(user_id))
    # Set role
    from(t in User, update: [set: [role: ^role]]) |> Repo.update_all([])
    sign_in_with_email(conn, %{email: user_payload.email, password: user_payload.password})
  end
end
