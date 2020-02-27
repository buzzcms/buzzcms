defmodule BuzzcmsWeb.Jwt do
  import BuzzcmsWeb.Auth.Guardian

  def sign(%{
        id: id,
        email: email,
        display_name: display_name,
        role: role,
        is_verified: is_verified
      }) do
    encode_and_sign(%{id: id}, %{
      email: email,
      display_name: display_name,
      is_verified: is_verified,
      role: role
    })
  end
end
