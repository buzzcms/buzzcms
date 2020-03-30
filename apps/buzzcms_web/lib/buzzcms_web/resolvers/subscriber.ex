defmodule BuzzcmsWeb.SubscriberResolver do
  @schema Buzzcms.Schema.Subscriber

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
        %{data: data},
        %{context: _}
      ) do
    result =
      struct(@schema)
      |> @schema.changeset(data)
      |> Repo.insert()

    case result do
      {:ok, result} ->
        subscriber = Repo.get(@schema, result.id)
        form = Repo.get(Buzzcms.Schema.Form, result.form_id)
        send_mails(form, subscriber)
        {:ok, %{result: %{node: subscriber}}}

      {:error, changeset = %Ecto.Changeset{}} ->
        {:error, %{message: BuzzcmsWeb.Helpers.error_text(changeset)}}

      {:error, _} ->
        {:error, "Unknown errors"}
    end
  end

  defp send_mails(
         %{
           thank_you_template: thank_you_template,
           notify_template: notify_template,
           send_from_email: send_from_email,
           notify_emails: notify_emails
         },
         %{email: subscriber_email, phone: phone, name: name, data: data} = _subscriber
       ) do
    addition_data =
      data
      |> Enum.filter(fn {k, _} -> is_bitstring(k) end)
      |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)

    options = [email: subscriber_email, phone: phone, name: name] ++ addition_data

    thank_you_email =
      BuzzcmsWeb.Helpers.EmailFactory.make_email(
        send_from_email,
        subscriber_email,
        thank_you_template,
        options
      )
      |> BuzzcmsWeb.Mailer.deliver_later()

    notify_emails
    |> Enum.each(
      &(BuzzcmsWeb.Helpers.EmailFactory.make_email(
          send_from_email,
          &1,
          notify_template,
          options
        )
        |> BuzzcmsWeb.Mailer.deliver_later())
    )

    IO.inspect(thank_you_email, label: "Thank you")
    IO.inspect(notify_emails, label: "Notify")
  end

  defp send_mails(_form, _subscriber) do
  end
end
