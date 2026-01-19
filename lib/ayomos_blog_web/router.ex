defmodule AyomosBlogWeb.Router do
  use AyomosBlogWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AyomosBlogWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug AyomosBlogWeb.Plugs.TrackPageView
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin_auth do
    plug AyomosBlogWeb.Plugs.AdminAuth
  end

  scope "/", AyomosBlogWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/about", PageController, :about
    get "/contact", ContactController, :new
    post "/contact", ContactController, :create
    get "/blog", PostController, :blog_index
    get "/blog/:slug", PostController, :show_by_slug

    # Admin access verification endpoint
    post "/verify-admin", PageController, :verify_admin
  end

  # Bypass admin route - always works
  scope "/admin-ayo", AyomosBlogWeb do
    pipe_through [:browser, :admin_auth]

    get "/", AdminController, :dashboard
    get "/posts", PostController, :index
    get "/posts/new", PostController, :new
    post "/posts", PostController, :create
    get "/posts/:id/edit", PostController, :edit
    put "/posts/:id", PostController, :update
    patch "/posts/:id", PostController, :update
    delete "/posts/:id", PostController, :delete
  end

  scope "/admin", AyomosBlogWeb do
    pipe_through [:browser, :admin_auth]

    get "/", AdminController, :dashboard
    get "/posts", PostController, :index
    get "/posts/new", PostController, :new
    post "/posts", PostController, :create
    get "/posts/:id/edit", PostController, :edit
    put "/posts/:id", PostController, :update
    patch "/posts/:id", PostController, :update
    delete "/posts/:id", PostController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", AyomosBlogWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ayomos_blog, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AyomosBlogWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
