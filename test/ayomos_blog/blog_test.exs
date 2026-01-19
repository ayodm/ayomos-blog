defmodule AyomosBlog.BlogTest do
  use AyomosBlog.DataCase

  alias AyomosBlog.Blog

  describe "posts" do
    alias AyomosBlog.Blog.Post

    import AyomosBlog.BlogFixtures

    @invalid_attrs %{title: nil, body: nil, slug: nil, excerpt: nil, published: nil, published_at: nil}

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Blog.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Blog.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{title: "some title", body: "some body", slug: "some slug", excerpt: "some excerpt", published: true, published_at: ~U[2026-01-18 06:51:00Z]}

      assert {:ok, %Post{} = post} = Blog.create_post(valid_attrs)
      assert post.title == "some title"
      assert post.body == "some body"
      assert post.slug == "some slug"
      assert post.excerpt == "some excerpt"
      assert post.published == true
      assert post.published_at == ~U[2026-01-18 06:51:00Z]
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      update_attrs = %{title: "some updated title", body: "some updated body", slug: "some updated slug", excerpt: "some updated excerpt", published: false, published_at: ~U[2026-01-19 06:51:00Z]}

      assert {:ok, %Post{} = post} = Blog.update_post(post, update_attrs)
      assert post.title == "some updated title"
      assert post.body == "some updated body"
      assert post.slug == "some updated slug"
      assert post.excerpt == "some updated excerpt"
      assert post.published == false
      assert post.published_at == ~U[2026-01-19 06:51:00Z]
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Blog.update_post(post, @invalid_attrs)
      assert post == Blog.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Blog.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Blog.change_post(post)
    end
  end
end
