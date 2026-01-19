defmodule AyomosBlog.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :slug, :string
    field :excerpt, :string
    field :body, :string
    field :published, :boolean, default: false
    field :published_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :slug, :excerpt, :body, :published, :published_at])
    |> validate_required([:title, :slug, :excerpt, :body, :published, :published_at])
    |> unique_constraint(:slug)
  end
end
