defmodule AyomosBlog.Analytics do
  @moduledoc """
  The Analytics context for tracking site metrics.
  """

  import Ecto.Query, warn: false
  alias AyomosBlog.Repo
  alias AyomosBlog.Analytics.PageView

  @doc """
  Records a page view.
  """
  def track_page_view(attrs) do
    %PageView{}
    |> PageView.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns total page views.
  """
  def total_page_views do
    Repo.aggregate(PageView, :count)
  end

  @doc """
  Returns page views for today.
  """
  def page_views_today do
    today = Date.utc_today()

    from(p in PageView,
      where: fragment("date(inserted_at) = ?", ^today)
    )
    |> Repo.aggregate(:count)
  end

  @doc """
  Returns page views for the last 7 days.
  """
  def page_views_last_7_days do
    seven_days_ago = DateTime.utc_now() |> DateTime.add(-7, :day)

    from(p in PageView,
      where: p.inserted_at >= ^seven_days_ago
    )
    |> Repo.aggregate(:count)
  end

  @doc """
  Returns page views for the last 30 days.
  """
  def page_views_last_30_days do
    thirty_days_ago = DateTime.utc_now() |> DateTime.add(-30, :day)

    from(p in PageView,
      where: p.inserted_at >= ^thirty_days_ago
    )
    |> Repo.aggregate(:count)
  end

  @doc """
  Returns unique visitors (by IP hash) for today.
  """
  def unique_visitors_today do
    today = Date.utc_today()

    from(p in PageView,
      where: fragment("date(inserted_at) = ?", ^today),
      select: count(p.ip_hash, :distinct)
    )
    |> Repo.one()
  end

  @doc """
  Returns top pages by views.
  """
  def top_pages(limit \\ 10) do
    from(p in PageView,
      group_by: p.path,
      select: {p.path, count(p.id)},
      order_by: [desc: count(p.id)],
      limit: ^limit
    )
    |> Repo.all()
  end

  @doc """
  Returns top referrers.
  """
  def top_referrers(limit \\ 10) do
    from(p in PageView,
      where: not is_nil(p.referrer) and p.referrer != "",
      group_by: p.referrer,
      select: {p.referrer, count(p.id)},
      order_by: [desc: count(p.id)],
      limit: ^limit
    )
    |> Repo.all()
  end

  @doc """
  Returns page views grouped by day for the last N days.
  """
  def views_by_day(days \\ 30) do
    start_date = DateTime.utc_now() |> DateTime.add(-days, :day)

    from(p in PageView,
      where: p.inserted_at >= ^start_date,
      group_by: fragment("date(inserted_at)"),
      select: {fragment("date(inserted_at)"), count(p.id)},
      order_by: [asc: fragment("date(inserted_at)")]
    )
    |> Repo.all()
  end

  @doc """
  Returns recent page views.
  """
  def recent_page_views(limit \\ 20) do
    from(p in PageView,
      order_by: [desc: p.inserted_at],
      limit: ^limit
    )
    |> Repo.all()
  end

  @doc """
  Returns page view stats summary.
  """
  def get_stats do
    %{
      total: total_page_views(),
      today: page_views_today(),
      last_7_days: page_views_last_7_days(),
      last_30_days: page_views_last_30_days(),
      unique_today: unique_visitors_today() || 0,
      top_pages: top_pages(5),
      top_referrers: top_referrers(5)
    }
  end
end
