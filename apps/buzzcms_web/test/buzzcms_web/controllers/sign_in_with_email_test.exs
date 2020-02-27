defmodule BuzzcmsWeb.SignInWithEmailTest do
  use BuzzcmsWeb.ConnCase
  import Buzzcms.Factory
  import BuzzcmsWeb.ControllerTestUtils

  describe "sign in with email" do
    @tag :wip
    test "valid", %{conn: conn, valid_params: params} do
      conn = post(conn, "/auth/identity/callback", params)
      assert %{"access_token" => _} = json_response(conn, 200)
    end

    test "token has valid payload", %{conn: conn, valid_params: params} do
      conn = post(conn, "/auth/identity/callback", params)
      assert %{"access_token" => token} = json_response(conn, 200)

      assert {:ok,
              %{
                "aud" => "buzzcms",
                "display_name" => "User",
                "is_verified" => true,
                "iss" => "buzzcms",
                "role" => "customer",
                "typ" => "access"
              }} = BuzzcmsWeb.Auth.Guardian.decode_and_verify(token)
    end

    @tag :wip
    test "missing password", %{conn: conn, valid_params: params} do
      conn = post(conn, "/auth/identity/callback", %{params | password: nil})
      assert %{"error" => "Missing password"} = json_response(conn, 400)
    end

    @tag :wip
    test "invalid credentials", %{conn: conn, valid_params: params} do
      conn = post(conn, "/auth/identity/callback", %{params | password: "wrongpass"})
      assert %{"error" => "Invalid credentials"} = json_response(conn, 400)
    end

    setup %{conn: conn} do
      user_payload = build(:email_signup_payload)
      %{user_id: user_id} = sign_up_with_email(conn, user_payload) |> decode_token()
      token = get_verify_token(user_id)
      verify_user_email(conn, user_id, token) |> json_response(200)

      {:ok,
       valid_params: %{
         email: user_payload.email,
         password: user_payload.password
       }}
    end
  end
end
