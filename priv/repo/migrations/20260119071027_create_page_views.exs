defmodule AyomosBlog.Repo.Migrations.CreatePageViews do
  use Ecto.Migration

  def change do
    create table(:page_views) do
      add :path, :string
      add :ip_hash, :string
      add :user_agent, :string
      add :referrer, :string
      add :country, :string

      timestamps(type: :utc_datetime)
    end
  end
end
