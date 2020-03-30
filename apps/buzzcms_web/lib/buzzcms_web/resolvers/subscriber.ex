defmodule BuzzcmsWeb.SubscriberResolver do
  @schema Buzzcms.Schema.Subscriber
  import Ecto.Query
  alias Buzzcms.Schema.Form

  @filter_definition [
    fields: [
      {:email, FilterParser.StringFilterInput},
      {:phone, FilterParser.StringFilterInput},
      {:name, FilterParser.StringFilterInput},
      {:form_id, FilterParser.IdFilterInput},
      {:created_at, FilterParser.DateTimeFilterInput}
    ]
  ]

  use BuzzcmsWeb.Resolver

  def create(
        %{data: %{form_id: form_id} = data},
        %{context: _}
      ) do
    result =
      struct(@schema)
      |> @schema.changeset(data)
      |> Repo.insert()

    case result do
      {:ok, result} ->
        subscriber = Repo.get(@schema, result.id)
        get_templates(form_id) |> send_mails(subscriber)
        {:ok, %{result: %{node: subscriber}}}

      {:error, changeset = %Ecto.Changeset{}} ->
        {:error, %{message: BuzzcmsWeb.Helpers.error_text(changeset)}}

      {:error, _} ->
        {:error, "Unknown errors"}
    end
  end

  defp get_templates(form_id) do
    Repo.get(Form, form_id)
    |> Repo.preload(thank_you_template: [:email_sender], notify_template: [:email_sender])
  end

  defp send_mails(
         %Form{
           thank_you_template: thank_you_template,
           notify_template: notify_template,
           notify_emails: notify_emails
         },
         %{email: subscriber_email, phone: phone, name: name, data: data} = _subscriber
       ) do
    addition_data =
      data
      |> Enum.filter(fn {k, _} -> is_bitstring(k) end)
      |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)

    options = [email: subscriber_email, phone: phone, name: name] ++ addition_data

    BuzzcmsWeb.Helpers.EmailFactory.make_email(
      thank_you_template,
      subscriber_email,
      options
    )
    |> BuzzcmsWeb.Mailer.deliver_later()

    # |> IO.inspect(label: "Thank you email")

    notify_emails
    |> Enum.each(
      &(BuzzcmsWeb.Helpers.EmailFactory.make_email(
          notify_template,
          &1,
          options
        )
        |> BuzzcmsWeb.Mailer.deliver_later())
    )

    # |> IO.inspect(label: "Notify emails")
  end

  defp send_mails(_form, _subscriber) do
  end
end
