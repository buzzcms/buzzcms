defmodule Buzzcms.Users do
  @moduledoc """
  Keep logic about users
  """

  alias Buzzcms.Repo
  alias Buzzcms.Schema.User

  def get!(id) do
    Repo.get!(User, id)
  end

  def verify_email do
  end

  def sign_in_with_facebook do
  end

  def sign_in_with_google do
  end
end
