defmodule AyomosBlogWeb.Plugs.SecurityHeaders do
  @moduledoc """
  Adds comprehensive security headers to all responses.

  Protects against:
  - XSS attacks
  - Clickjacking
  - MIME sniffing
  - Protocol downgrade attacks
  - Information leakage
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    # Prevent XSS attacks
    |> put_resp_header("x-xss-protection", "1; mode=block")

    # Prevent clickjacking
    |> put_resp_header("x-frame-options", "SAMEORIGIN")

    # Prevent MIME type sniffing
    |> put_resp_header("x-content-type-options", "nosniff")

    # Referrer policy - don't leak internal URLs
    |> put_resp_header("referrer-policy", "strict-origin-when-cross-origin")

    # Permissions policy - restrict browser features
    |> put_resp_header("permissions-policy",
      "accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), payment=(), usb=()"
    )

    # Content Security Policy
    |> put_resp_header("content-security-policy", build_csp())

    # HSTS - force HTTPS (only effective in production)
    |> put_resp_header("strict-transport-security", "max-age=31536000; includeSubDomains")

    # Hide server info
    |> delete_resp_header("x-powered-by")
    |> delete_resp_header("server")
  end

  defp build_csp do
    [
      "default-src 'self'",
      "script-src 'self' 'unsafe-inline' 'unsafe-eval'",  # Needed for Phoenix LiveView
      "style-src 'self' 'unsafe-inline'",  # Needed for Tailwind
      "img-src 'self' data: https:",
      "font-src 'self' data:",
      "connect-src 'self' wss:",  # WebSocket for LiveView
      "frame-ancestors 'self'",
      "form-action 'self'",
      "base-uri 'self'"
    ]
    |> Enum.join("; ")
  end
end
