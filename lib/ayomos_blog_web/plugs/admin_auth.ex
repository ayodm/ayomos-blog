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
  Uses constant-time comparison to prevent timing attacks.
  """
  def valid_code?(code) do
    # Use Plug.Crypto for constant-time comparison
    Plug.Crypto.secure_compare(code || "", @admin_code)
  end

  @doc """
  Clears the admin session token.
  """
  def logout(conn) do
    delete_session(conn, @admin_token_key)
  end

  @doc """
  Logs admin access attempts for security auditing.
  """
  def log_access_attempt(conn, success) do
    ip = get_client_ip(conn)
    timestamp = DateTime.utc_now() |> DateTime.to_iso8601()
    status = if success, do: "SUCCESS", else: "FAILED"

    # Log to console/file
    require Logger
    Logger.warning("[ADMIN_ACCESS] #{status} from IP: #{ip} at #{timestamp}")
  end

  defp get_client_ip(conn) do
    forwarded = Plug.Conn.get_req_header(conn, "fly-client-ip") |> List.first()
    x_forwarded = Plug.Conn.get_req_header(conn, "x-forwarded-for") |> List.first()
    x_real_ip = Plug.Conn.get_req_header(conn, "x-real-ip") |> List.first()

    cond do
      forwarded -> forwarded
      x_forwarded -> x_forwarded |> String.split(",") |> List.first() |> String.trim()
      x_real_ip -> x_real_ip
      true -> conn.remote_ip |> :inet.ntoa() |> to_string()
    end
  end
end
