defmodule Buzzcms.Tokens do
  import Ecto.Query, only: [from: 2]
  alias Buzzcms.Repo
  alias Buzzcms.Schema.Token

  def create_token(user_id, type) do
    %Token{}
    |> Token.changeset(%{user_id: user_id, type: type})
    |> Repo.insert!()
  end

  def mark_token_as_used(token) do
    from(t in Token,
      where: t.token == ^token,
      update: [set: [is_used: true]]
    )
    |> Repo.update_all([])
  end

  def verify_token(user_id, token, type) do
    query =
      from t in Token,
        where: t.token == ^token and t.type == ^type and t.user_id == ^user_id,
        select: %{
          user_id: t.user_id,
          is_used: t.is_used,
          is_expired: fragment("now() + interval '1s' > ?", t.expired_at)
        }

    case Repo.one(query) do
      %{is_expired: false, is_used: false} ->
        :ok

      %{is_expired: true} ->
        {:error, "Token is expired"}

      %{is_used: true} ->
        {:error, "Token is used"}

      nil ->
        {:error, "Invalid token"}
    end
  end
end
