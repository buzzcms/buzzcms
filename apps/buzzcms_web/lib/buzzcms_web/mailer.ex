defmodule BuzzcmsWeb.Mailer do
  use Bamboo.Mailer, otp_app: :buzzcms_web
  import Ecto.Query, only: [from: 2]
  alias Buzzcms.Repo
  alias Buzzcms.Schema.{EmailTemplate, Token, User}

  def send_mail_by_token(token) do
    case make_email(token) do
      {:error, reason} -> {:error, reason}
      email -> deliver_later(email)
    end
  end

  defp make_email(token) do
    token = Repo.one(from t in Token, where: t.token == ^token)

    case token do
      %Token{} = token ->
        get_email_template(token)

      nil ->
        {:error, "Token is not valid"}
    end
  end

  defp get_email_template(%Token{
         user_id: user_id,
         type: type,
         token: token
       }) do
    template =
      Repo.one(
        from t in EmailTemplate,
          where: t.code == ^type and t.is_system == true
      )
      |> Repo.preload([:email_sender])

    case template do
      nil ->
        {:error, "Cannot find email template"}

      %EmailTemplate{} = template ->
        BuzzcmsWeb.Helpers.EmailFactory.make_email(
          template,
          Repo.get(User, user_id),
          token: token
        )
    end
  end
end

defimpl Bamboo.Formatter, for: Buzzcms.Schema.User do
  # Used by `to`, `bcc`, `cc` and `from`
  def format_email_address(user, _opts) do
    {user.display_name, user.email}
  end
end

defimpl Bamboo.Formatter, for: Buzzcms.Schema.EmailSender do
  # Used by `to`, `bcc`, `cc` and `from`
  def format_email_address(user, _opts) do
    {user.name, user.email}
  end
end
