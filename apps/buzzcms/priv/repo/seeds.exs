# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Buzzcms.Repo.insert!(%Buzzcms.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
Buzzcms.Repo.insert!(%Buzzcms.Schema.AuthProvider{value: "email"})
Buzzcms.Repo.insert!(%Buzzcms.Schema.Role{value: "admin"})
Buzzcms.Repo.insert!(%Buzzcms.Schema.Role{value: "contributor"})
Buzzcms.Repo.insert!(%Buzzcms.Schema.Role{value: "customer", is_default: true})
Buzzcms.Repo.insert!(%Buzzcms.Schema.EntryType{code: "post", display_name: "Post"})

email_templates = [
  %{
    type: "verify_email",
    subject: "Verify your email",
    html: "Please click the link <%= link %>",
    text: "Please click the link: <%= link %>",
    link: "https://dew.vn/verify-email"
  },
  %{
    type: "reset_password",
    subject: "Reset your password",
    html: "Please click the link <%= link %>",
    text: "Please click the link: <%= link %>",
    link: "https://dew.vn/forget-password"
  }
]

Buzzcms.Repo.insert_all(Buzzcms.Schema.EmailTemplate, email_templates)
