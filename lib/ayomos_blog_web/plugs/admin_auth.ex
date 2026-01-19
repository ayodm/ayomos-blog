defmodule AyomosBlogWeb.Plugs.AdminAuth do
  @moduledoc """
  Plug to restrict admin access to authorized devices only.

  Access is granted if:
  1. The route is /admin-ayo (bypass route)
  2. The session has a valid admin_token

  Otherwise, redirects to a rick-roll.
  """
  import Plug.Conn
  import Phoenix.Controller

  # Set your secret admin code here
  @admin_code "ayomos2026"

  # Token that gets stored in session when authenticated
  @admin_token_key "admin_device_token"
  @valid_token "ayo_authorized_device_v1"

  def init(opts), do: opts

  def call(conn, _opts) do
    cond do
      # Bypass route - always allow
      conn.request_path == "/admin-ayo" or String.starts_with?(conn.request_path, "/admin-ayo/") ->
        conn
        |> put_session(@admin_token_key, @valid_token)
        |> assign(:admin_bypass, true)

      # Check if device is authorized via session token
      get_session(conn, @admin_token_key) == @valid_token ->
        conn

      # Not authorized - rick-roll!
      true ->
        conn
        |> redirect(external: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
        |> halt()
    end
  end

  @doc """
  Verifies the admin code and sets the device token if correct.
  Returns {:ok, conn} if code is valid, {:error, conn} otherwise.
  """
  def verify_code(conn, code) do
    if code == @admin_code do
      {:ok, put_session(conn, @admin_token_key, @valid_token)}
    else
      {:error, conn}
    end
  end

  @doc """
  Checks if the provided code matches the admin code.
  """
  def valid_code?(code) do
    code == @admin_code
  end

  @doc """
  Clears the admin session token.
  """
  def logout(conn) do
    delete_session(conn, @admin_token_key)
  end
end
