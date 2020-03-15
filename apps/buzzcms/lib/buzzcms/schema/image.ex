defmodule Buzzcms.Schema.Image do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [
    :id,
    :name,
    :ext,
    :size,
    :status
  ]

  @optional_fields [
    :mime,
    :width,
    :height,
    :remote_url,
    :caption
  ]

  @primary_key {:id, :string, []}

  @derive {Jason.Encoder,
   only: [
     :id,
     :name,
     :ext,
     :mime,
     :caption,
     :width,
     :height,
     :size
     #  :created_at,
     #  :modified_at
   ]}

  schema "image" do
    field :remote_url, :string
    field :name, :string
    field :ext, :string
    field :mime, :string
    field :caption, :string
    field :width, :decimal
    field :height, :decimal
    field :size, :decimal
    field :status, :string
    field :created_at, :utc_datetime
    field :modified_at, :utc_datetime
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
