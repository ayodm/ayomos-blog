defmodule AyomosBlogWeb.Plugs.TrackPageView do
  @moduledoc """
  Plug to track page views for analytics.
  """

  import Plug.Conn
  alias AyomosBlog.Analytics

  def init(opts), do: opts

  def call(conn, _opts) do
    # Only track GET requests to avoid tracking form submissions
    if conn.method == "GET" do
      # Don't track admin pages, assets, or dev routes
      unless should_skip?(conn.request_path) do
        Task.start(fn ->
          track_view(conn)
        end)
      end
    end

    conn
  end

  defp should_skip?(path) do
    String.starts_with?(path, "/admin") or
    String.starts_with?(path, "/dev") or
    String.starts_with?(path, "/assets") or
    String.starts_with?(path, "/api") or
    String.starts_with?(path, "/favicon")
  end

  defp track_view(conn) do
    ip = get_client_ip(conn)
    ip_hash = :crypto.hash(:sha256, ip) |> Base.encode16() |> String.slice(0, 16)

    user_agent = get_header(conn, "user-agent")
    referrer = get_header(conn, "referer")

    Analytics.track_page_view(%{
      path: conn.request_path,
      ip_hash: ip_hash,
      user_agent: user_agent,
      referrer: referrer,
      country: nil  # Could integrate with IP geolocation service
    })
  end

  defp get_client_ip(conn) do
    # Check for forwarded IP (behind proxy/load balancer)
    forwarded = get_header(conn, "x-forwarded-for")

    if forwarded do
      forwarded |> String.split(",") |> List.first() |> String.trim()
    else
      conn.remote_ip |> :inet.ntoa() |> to_string()
    end
  end

  defp get_header(conn, name) do
    case get_req_header(conn, name) do
      [value | _] -> value
      [] -> nil
    end
  end
end
