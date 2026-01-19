defmodule AyomosBlogWeb.AdminController do
  use AyomosBlogWeb, :controller

  alias AyomosBlog.Analytics
  alias AyomosBlog.Blog

  def dashboard(conn, _params) do
    stats = Analytics.get_stats()
    posts = Blog.list_posts()
    recent_views = Analytics.recent_page_views(15)
    views_by_day = Analytics.views_by_day(14)

    conn
    |> assign(:page_title, "CMS Dashboard")
    |> render(:dashboard,
      stats: stats,
      posts: posts,
      recent_views: recent_views,
      views_by_day: views_by_day
    )
  end
end
