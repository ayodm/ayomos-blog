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
    if AdminAuth.valid_code?(code) do
      AdminAuth.log_access_attempt(conn, true)

      {:ok, conn} = AdminAuth.verify_code(conn, code)
      conn
      |> put_flash(:info, "Access granted. Welcome back.")
      |> redirect(to: "/admin")
    else
      AdminAuth.log_access_attempt(conn, false)

      # Add delay to slow down brute force attacks
      Process.sleep(2000)

      conn
      |> put_flash(:error, "Access denied")
      |> redirect(to: "/")
    end
  end

  # Handle missing code parameter
  def verify_admin(conn, _params) do
    AdminAuth.log_access_attempt(conn, false)

    conn
    |> put_flash(:error, "Access denied")
    |> redirect(to: "/")
  end
end
