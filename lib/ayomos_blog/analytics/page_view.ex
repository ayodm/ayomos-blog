defmodule AyomosBlog.Analytics.PageView do
  use Ecto.Schema
  import Ecto.Changeset

  schema "page_views" do
    field :path, :string
    field :ip_hash, :string
    field :user_agent, :string
    field :referrer, :string
    field :country, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(page_view, attrs) do
    page_view
    |> cast(attrs, [:path, :ip_hash, :user_agent, :referrer, :country])
    |> validate_required([:path, :ip_hash, :user_agent, :referrer, :country])
  end
end
