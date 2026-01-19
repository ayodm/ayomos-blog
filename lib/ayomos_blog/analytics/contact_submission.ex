defmodule AyomosBlog.Analytics.ContactSubmission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "contact_submissions" do
    field :name, :string
    field :email, :string
    field :subject, :string
    field :message, :string
    field :ip_hash, :string
    field :user_agent, :string
    field :status, :string, default: "pending"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(submission, attrs) do
    submission
    |> cast(attrs, [:name, :email, :subject, :message, :ip_hash, :user_agent, :status])
    |> validate_required([:name, :email, :message])
    |> validate_format(:email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/)
    |> validate_length(:name, min: 2, max: 100)
    |> validate_length(:message, min: 10, max: 5000)
    |> validate_inclusion(:status, ["pending", "read", "replied", "spam"])
  end
end
