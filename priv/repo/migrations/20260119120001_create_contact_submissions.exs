defmodule AyomosBlog.Repo.Migrations.CreateContactSubmissions do
  use Ecto.Migration

  def change do
    create table(:contact_submissions) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :subject, :string
      add :message, :text, null: false
      add :ip_hash, :string
      add :user_agent, :string
      add :status, :string, default: "pending"  # pending, read, replied, spam

      timestamps(type: :utc_datetime)
    end

    create index(:contact_submissions, [:status])
    create index(:contact_submissions, [:inserted_at])
  end
end
