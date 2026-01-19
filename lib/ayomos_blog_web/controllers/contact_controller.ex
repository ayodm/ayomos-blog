defmodule AyomosBlogWeb.ContactController do
  use AyomosBlogWeb, :controller

  alias AyomosBlog.Contact

  def new(conn, _params) do
    conn
    |> assign(:page_title, "Contact")
    |> render(:new, errors: [], success: false)
  end

  def create(conn, %{"contact" => contact_params}) do
    # Check for timing-based bot detection (form submitted too fast)
    _form_token = Map.get(contact_params, "form_token", "")

    case Contact.validate_submission(contact_params) do
      {:ok, data} ->
        # Get client metadata
        ip = get_client_ip(conn)
        ip_hash = :crypto.hash(:sha256, ip) |> Base.encode16() |> String.slice(0, 16)
        user_agent = get_req_header(conn, "user-agent") |> List.first() || ""

        # Save to database
        metadata = %{ip_hash: ip_hash, user_agent: user_agent}
        Contact.save_submission(data, metadata)

        # Send email asynchronously
        Task.start(fn ->
          Contact.send_contact_email(data)
        end)

        conn
        |> assign(:page_title, "Contact")
        |> put_flash(:info, "Thank you! Your message has been sent. I'll get back to you soon.")
        |> render(:new, errors: [], success: true)

      {:error, errors} ->
        conn
        |> assign(:page_title, "Contact")
        |> put_flash(:error, "Please fix the errors below.")
        |> render(:new, errors: errors, success: false, form_data: contact_params)

      {:spam, _} ->
        # Fake success for spam - don't let bots know they failed
        conn
        |> assign(:page_title, "Contact")
        |> put_flash(:info, "Thank you! Your message has been sent.")
        |> render(:new, errors: [], success: true)
    end
  end

  # Fallback for missing params
  def create(conn, _params) do
    conn
    |> assign(:page_title, "Contact")
    |> put_flash(:error, "Please fill out the contact form.")
    |> render(:new, errors: [], success: false)
  end

  defp get_client_ip(conn) do
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
end
