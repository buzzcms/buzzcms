defmodule BuzzcmsWeb.Helpers.EmailFactory do
  import Bamboo.Email

  def make_email(from, to, %{subject: _, body_html: _} = template, payload)
      when is_binary(from) and is_bitstring(to) do
    make_email(template, payload) |> from(from) |> to(to)
  end

  def make_email(_from, _to, _template, _payload) do
  end

  defp make_email(template, payload) do
    new_email(
      subject: EEx.eval_string(template.subject, payload),
      html_body: EEx.eval_string(template.body_html, payload),
      text_body: EEx.eval_string(template.body_text, payload)
    )
  end
end
