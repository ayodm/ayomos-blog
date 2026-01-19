defmodule AyomosBlogWeb.PostController do
  use AyomosBlogWeb, :controller

  alias AyomosBlog.Blog
  alias AyomosBlog.Blog.Post

  # Public blog index
  def blog_index(conn, _params) do
    posts = Blog.list_published_posts()

    conn
    |> assign(:page_title, "Blog")
    |> render(:index, posts: posts)
  end

  # Admin posts index
  def index(conn, _params) do
    posts = Blog.list_posts()

    conn
    |> assign(:page_title, "Manage Posts")
    |> render(:admin_index, posts: posts)
  end

  def show_by_slug(conn, %{"slug" => slug}) do
    post = Blog.get_post_by_slug!(slug)

    conn
    |> assign(:page_title, post.title)
    |> render(:show, post: post)
  end

  def new(conn, _params) do
    changeset = Blog.change_post(%Post{})

    conn
    |> assign(:page_title, "New Post")
    |> render(:new, changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    case Blog.create_post(post_params) do
      {:ok, _post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: ~p"/admin/posts")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Blog.get_post!(id)
    render(conn, :show, post: post)
  end

  def edit(conn, %{"id" => id}) do
    post = Blog.get_post!(id)
    changeset = Blog.change_post(post)

    conn
    |> assign(:page_title, "Edit Post")
    |> render(:edit, post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Blog.get_post!(id)

    case Blog.update_post(post, post_params) do
      {:ok, _post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: ~p"/admin/posts")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Blog.get_post!(id)
    {:ok, _post} = Blog.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: ~p"/admin/posts")
  end
end
