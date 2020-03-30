defmodule BuzzcmsWeb.Helpers.EmailFactory do
  import Bamboo.Email
  alias Buzzcms.Schema.{EmailTemplate, User}

  def make_email(%EmailTemplate{} = template, to, payload) when is_bitstring(to) do
    make_email(template, payload) |> to(to)
  end

  def make_email(%EmailTemplate{} = template, %User{} = to, payload) do
    make_email(template, payload) |> to(to)
  end

  def make_email(_from, _to, _template, _payload) do
  end

  defp make_email(
         %EmailTemplate{
           email_sender: from,
           html: html,
           text: text,
           subject: subject
         },
         payload
       ) do
    new_email(
      from: from,
      subject: EEx.eval_string(subject, payload),
      html_body: EEx.eval_string(html, payload),
      text_body: EEx.eval_string(text, payload)
    )
  end
end
