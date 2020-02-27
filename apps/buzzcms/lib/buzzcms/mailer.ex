defmodule Buzzcms.Mailer do
  use Bamboo.Mailer, otp_app: :buzzcms
  import Ecto.Query, only: [from: 2]
  alias Buzzcms.Repo
  alias Buzzcms.Schema.{EmailTemplate, EmailSender, Token, User}

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
    query =
      from t in EmailTemplate,
        left_join: es in EmailSender,
        on: es.id == t.email_sender_id,
        where: t.type == ^type,
        select: [t, es]

    template = Repo.one(query)
    to = Repo.get(User, user_id)

    case template do
      nil ->
        {:error, "Cannot find email template"}

      [_, nil] ->
        {:error, "Cannot find email sender"}

      [
        %EmailTemplate{subject: subject, html: html, text: text, link: link},
        %EmailSender{} = from
      ] ->
        link = "#{link}?token=#{token}"

        Bamboo.Email.new_email(
          to: to,
          from: from,
          subject: subject,
          html_body: EEx.eval_string(html, link: link),
          text_body: EEx.eval_string(text, link: link)
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
