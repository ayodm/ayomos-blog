defmodule AyomosBlog.Repo do
  use Ecto.Repo,
    otp_app: :ayomos_blog,
    adapter: Ecto.Adapters.Postgres
end
