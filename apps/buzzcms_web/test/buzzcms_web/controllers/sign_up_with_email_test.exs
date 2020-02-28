defmodule BuzzcmsWeb.SignUpToSystemProjectTest do
  use BuzzcmsWeb.ConnCase
  use Bamboo.Test
  import Buzzcms.Factory
  import BuzzcmsWeb.ControllerTestUtils
  alias Buzzcms.Repo
  alias Buzzcms.Schema.{User, Token}

  describe "Sign up with email" do
    test "valid payload", %{conn: conn} do
      user_payload = build(:email_signup_payload)
      %{user_id: user_id} = sign_up_with_email(conn, user_payload) |> decode_token()
      create_email_sender()

      assert %{
               is_verified: false,
               role: "customer",
               auth_provider: "email"
             } = Repo.get(User, user_id)

      assert %{
               type: "verify_email",
               is_used: false,
               token: token
             } = Repo.one(Token, where: [type: "verify_email", user_id: user_id])

      email = BuzzcmsWeb.Mailer.send_mail_by_token(token)

      assert %Bamboo.Email{
               from: {"Sender", "hi@buzzcms.co"},
               to: [{"User", _}]
             } = email

      assert_delivered_email(email)
    end

    test "invalid email", %{conn: conn} do
      user_payload = build(:email_signup_payload, %{email: "not_an_email"})

      assert %{"errors" => %{"email" => ["has invalid format"]}} =
               sign_up_with_email(conn, user_payload) |> json_response(400)
    end

    test "password is not strong enough", %{conn: conn} do
      user_payload = build(:email_signup_payload, %{password: "123456"})

      assert %{"errors" => %{"password" => ["has invalid format"]}} =
               sign_up_with_email(conn, user_payload) |> json_response(400)
    end

    test "duplicate email", %{conn: conn} do
      user_payload = build(:email_signup_payload)

      %{"access_token" => _} = sign_up_with_email(conn, user_payload) |> json_response(200)

      assert %{"errors" => %{"email" => ["has already been taken"]}} =
               sign_up_with_email(conn, user_payload) |> json_response(400)
    end
  end

  describe "Verify user" do
    test "with valid token", %{conn: conn, token: token, user_id: user_id} do
      verify_user_email(conn, user_id, token) |> json_response(200)
      assert check_user_is_verified(user_id) == true
    end

    test "token is expired", %{conn: conn, token: token, user_id: user_id} do
      make_token_expired(token)

      assert %{"error" => "Token is expired"} =
               verify_user_email(conn, user_id, token) |> json_response(400)
    end

    test "token is used", %{conn: conn, token: token, user_id: user_id} do
      verify_user_email(conn, user_id, token) |> json_response(200)

      assert %{"error" => "Token is used"} =
               verify_user_email(conn, user_id, token) |> json_response(400)
    end

    test "invalid token", %{conn: conn, user_id: user_id} do
      assert %{"error" => "Invalid token"} =
               verify_user_email(conn, user_id, "invalid") |> json_response(400)
    end

    setup %{conn: conn} do
      user_payload = build(:email_signup_payload)
      %{user_id: user_id} = sign_up_with_email(conn, user_payload) |> decode_token()
      token = get_verify_token(user_id)
      {:ok, user_id: user_id, token: token}
    end
  end
end
