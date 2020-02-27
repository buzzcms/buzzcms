defmodule BuzzcmsWeb.Auth.Guardian do
  use Guardian, otp_app: :buzzcms_web

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(claims) do
    {:ok, claims}
  end
end
