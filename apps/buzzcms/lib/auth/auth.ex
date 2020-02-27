defmodule Buzzcms.Auth do
  import Ecto.Query, only: [from: 2]
  import Buzzcms.Users
  import Buzzcms.Tokens
  alias Ueberauth.Auth

  alias Buzzcms.Repo
  alias Buzzcms.{SignInWithEmailStruct, SignUpWithEmailStruct}
  alias Buzzcms.Schema.User

  def login(%Auth{provider: :identity} = auth) do
    %{
      email: auth.info.email,
      password: password_from_auth(auth)
    }
    |> sign_in_with_email
  end

  def sign_in_with_email(params) do
    case SignInWithEmailStruct.new(params) do
      %{password: nil} ->
        {:error, "Missing password"}

      params ->
        get_user(params)
    end
  end

  def sign_up_with_email(params) do
    params = SignUpWithEmailStruct.new(params)
    create_user(params)
  end

  defp create_user(params) do
    case %User{}
         |> User.sign_up_with_password_changeset(Map.from_struct(params))
         |> Repo.insert() do
      {:ok, %{id: user_id}} ->
        create_token(user_id, "verify_email") |> send_verification_token
        get!(user_id)

      {:error, error} ->
        error
    end
  end

  def verify_email(user_id, token) do
    case verify_token(user_id, token, "verify_email") do
      :ok ->
        Repo.get!(User, user_id, select: [:id]) |> User.verify_changeset() |> Repo.update()
        mark_token_as_used(token)
        :ok

      {:error, message} ->
        {:error, message}
    end
  end

  defp get_user(%{email: email, password: password}) do
    query = from(u in User, where: u.email == ^email)

    case Repo.one(query) do
      nil ->
        Bcrypt.check_pass(nil, password)

      u ->
        case Bcrypt.check_pass(u, password) do
          # Make it not easy to guest that user email is valid or not
          {:error, _reason} -> {:error, "Invalid credentials"}
          {:ok, user} -> user
        end
    end
  end

  defp send_verification_token(_params) do
  end

  defp password_from_auth(auth) do
    auth.credentials.other.password
  end
end
