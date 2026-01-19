defmodule AyomosBlogWeb.PageController do
  use AyomosBlogWeb, :controller

  alias AyomosBlog.Blog
  alias AyomosBlogWeb.Plugs.AdminAuth

  def home(conn, _params) do
    posts = Blog.latest_published_posts(3)
    render(conn, :home, posts: posts)
  end

  def about(conn, _params) do
    conn
    |> assign(:page_title, "About")
    |> render(:about)
  end

  def verify_admin(conn, %{"code" => code}) do
    case AdminAuth.verify_code(conn, code) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Access granted. Welcome back.")
        |> redirect(to: "/admin")

      {:error, _conn} ->
        conn
        |> put_flash(:error, "Invalid code")
        |> redirect(to: "/")
    end
  end
end
