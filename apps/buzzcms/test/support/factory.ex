defmodule Buzzcms.Factory do
  use ExMachina.Ecto, repo: Buzzcms.Repo
  use Buzzcms.UserFactory

  alias Buzzcms.Schema.{
    Entry,
    EntryType,
    Taxon,
    Taxonomy
  }

  def entry_factory do
    title = sequence(:title, &"Title #{&1}")
    slug = sequence(:slug, &"title-#{&1}")

    %Entry{
      title: title,
      slug: slug
    }
  end

  def entry_type_factory do
    %EntryType{}
  end

  def taxonomy_factory do
    %Taxonomy{code: "category", display_name: "Category"}
  end

  def taxon_factory do
    title = sequence(:title, &"Taxon #{&1}")
    slug = sequence(:slug, &"taxon-#{&1}")

    %Taxon{
      title: title,
      slug: slug
    }
  end

  def email_sender_factory do
    %Buzzcms.Schema.EmailSender{
      name: "Sender",
      email: "hi@buzzcms.co"
    }
  end
end
