defmodule Buzzcms.UserFactory do
  alias Buzzcms.Schema.User

  defmacro __using__(_opts) do
    quote do
      def email_signup_payload_factory do
        email = sequence(:email, &"user#{&1}@buzzcms.co")

        %{
          email: email,
          password: "S3cret",
          display_name: "User"
        }
      end

      def user_factory do
        display_name = sequence(:display_name, &"User #{&1}")
        email = sequence(:email, &"user#{&1}.buzzcms.co")

        %User{
          email: email,
          display_name: display_name
        }
      end
    end
  end
end
