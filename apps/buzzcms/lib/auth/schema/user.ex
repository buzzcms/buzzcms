defmodule Buzzcms.Schema.User do
  use Ecto.Schema
  import Bcrypt
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @derive {Jason.Encoder, only: [:email, :display_name, :nickname, :auth_provider]}

  schema "user" do
    field :email, :string
    field :display_name, :string
    field :nickname, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :auth_provider, :string
    field :role, :string
    field :is_verified, :boolean
    field :created_at, :utc_datetime
    field :modified_at, :utc_datetime
  end

  def changeset(entity, params) do
    entity |> cast(params, [:email, :role, :is_verified])
  end

  def sign_up_with_password_changeset(entity, params) do
    entity
    |> cast(params, [
      :email,
      :display_name,
      :nickname,
      :password,
      :auth_provider,
      :role,
      :is_verified
    ])
    |> validate_required([:email, :display_name, :password, :auth_provider])
    |> validate_format(:email, ~r/^\S+@\S+\.\S+$/)
    |> validate_format(:password, ~r/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$/)
    |> unique_constraint(:email, name: :user_email_auth_provider_unique)
    |> unique_constraint(:nickname, name: :user_nickname_auth_provider_unique)
    |> put_pass_hash()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    # IO.inspect(change(changeset, add_hash(password)))
    change(changeset, add_hash(password))
  end

  defp put_pass_hash(changeset), do: changeset

  def verify_changeset(entity) do
    entity |> cast(%{is_verified: true}, [:is_verified])
  end
end
