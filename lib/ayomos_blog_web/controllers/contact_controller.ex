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
end
