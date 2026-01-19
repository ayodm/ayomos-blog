defmodule AyomosBlogWeb.Plugs.RateLimiter do
  @moduledoc """
  Simple ETS-based rate limiter to prevent DDoS and brute force attacks.

  Limits requests per IP address within a time window.
  """
  import Plug.Conn
  import Phoenix.Controller

  @table_name :rate_limit_table
  @default_limit 100  # requests per window
  @window_ms 60_000   # 1 minute window
  @admin_limit 10     # stricter limit for admin routes
  @contact_limit 5    # very strict for contact form

  def init(opts), do: opts

  def call(conn, opts) do
    ensure_table_exists()

    ip = get_client_ip(conn)
    path = conn.request_path

    limit = get_limit_for_path(path, opts)
    key = {ip, get_bucket_key(path)}

    case check_rate(key, limit) do
      :ok ->
        conn

      :rate_limited ->
        conn
        |> put_status(429)
        |> put_view(html: AyomosBlogWeb.ErrorHTML)
        |> render("429.html")
        |> halt()
    end
  end

  defp ensure_table_exists do
    if :ets.whereis(@table_name) == :undefined do
      :ets.new(@table_name, [:set, :public, :named_table])
    end
  end

  defp get_client_ip(conn) do
    # Check for forwarded IP (behind proxy/load balancer like Fly.io)
    forwarded = get_req_header(conn, "fly-client-ip") |> List.first()
    x_forwarded = get_req_header(conn, "x-forwarded-for") |> List.first()
    x_real_ip = get_req_header(conn, "x-real-ip") |> List.first()

    cond do
      forwarded -> forwarded
      x_forwarded -> x_forwarded |> String.split(",") |> List.first() |> String.trim()
      x_real_ip -> x_real_ip
      true -> conn.remote_ip |> :inet.ntoa() |> to_string()
    end
  end

  defp get_limit_for_path(path, opts) do
    cond do
      String.starts_with?(path, "/admin") or String.starts_with?(path, "/verify-admin") ->
        Keyword.get(opts, :admin_limit, @admin_limit)

      String.starts_with?(path, "/contact") ->
        Keyword.get(opts, :contact_limit, @contact_limit)

      true ->
        Keyword.get(opts, :limit, @default_limit)
    end
  end

  defp get_bucket_key(path) do
    cond do
      String.starts_with?(path, "/admin") -> :admin
      String.starts_with?(path, "/verify-admin") -> :admin
      String.starts_with?(path, "/contact") -> :contact
      true -> :general
    end
  end

  defp check_rate(key, limit) do
    now = System.monotonic_time(:millisecond)
    window_start = now - @window_ms

    case :ets.lookup(@table_name, key) do
      [{^key, requests}] ->
        # Filter out old requests
        valid_requests = Enum.filter(requests, fn time -> time > window_start end)

        if length(valid_requests) >= limit do
          :rate_limited
        else
          :ets.insert(@table_name, {key, [now | valid_requests]})
          :ok
        end

      [] ->
        :ets.insert(@table_name, {key, [now]})
        :ok
    end
  end

  @doc """
  Cleans up old entries from the rate limit table.
  Should be called periodically.
  """
  def cleanup do
    ensure_table_exists()
    now = System.monotonic_time(:millisecond)
    window_start = now - @window_ms

    :ets.foldl(fn {key, requests}, acc ->
      valid_requests = Enum.filter(requests, fn time -> time > window_start end)
      if valid_requests == [] do
        :ets.delete(@table_name, key)
      else
        :ets.insert(@table_name, {key, valid_requests})
      end
      acc
    end, :ok, @table_name)
  end
end
