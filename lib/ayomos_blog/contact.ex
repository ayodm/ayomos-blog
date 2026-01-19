defmodule AyomosBlog.Contact do
  @moduledoc """
  Context for handling contact form submissions.

  Includes spam protection and email sending.
  """
  alias AyomosBlog.Mailer
  import Swoosh.Email

  @contact_email "info@ayomos.com"
  @from_email "noreply@ayomos.com"

  @doc """
  Validates contact form data.
  Returns {:ok, data} or {:error, errors}
  """
  def validate_submission(params) do
    errors = []

    # Check honeypot field (should be empty)
    honeypot = Map.get(params, "website", "") |> String.trim()
    if honeypot != "" do
      # Silently reject - don't tell bots they failed
      {:spam, %{}}
    else
      name = Map.get(params, "name", "") |> String.trim()
      email = Map.get(params, "email", "") |> String.trim()
      subject = Map.get(params, "subject", "") |> String.trim()
      message = Map.get(params, "message", "") |> String.trim()

      errors =
        errors
        |> validate_required(name, "name", "Name is required")
        |> validate_required(email, "email", "Email is required")
        |> validate_email(email)
        |> validate_required(message, "message", "Message is required")
        |> validate_length(name, "name", 2, 100)
        |> validate_length(subject, "subject", 0, 200)
        |> validate_length(message, "message", 10, 5000)
        |> validate_no_urls(message, "message")  # Spam often contains URLs

      if errors == [] do
        {:ok, %{name: name, email: email, subject: subject, message: message}}
      else
        {:error, errors}
      end
    end
  end

  @doc """
  Sends the contact email.
  """
  def send_contact_email(%{name: name, email: email, subject: subject, message: message}) do
    email_subject = if subject == "", do: "Contact from #{name}", else: "#{subject} - from #{name}"

    new()
    |> to(@contact_email)
    |> from({name, @from_email})
    |> reply_to({name, email})
    |> subject("[ayomos.com] #{email_subject}")
    |> html_body("""
    <div style="font-family: monospace; max-width: 600px; margin: 0 auto; border: 2px solid #000; padding: 20px;">
      <h2 style="border-bottom: 2px solid #000; padding-bottom: 10px;">New Contact Form Submission</h2>

      <p><strong>From:</strong> #{html_escape(name)}</p>
      <p><strong>Email:</strong> <a href="mailto:#{html_escape(email)}">#{html_escape(email)}</a></p>
      <p><strong>Subject:</strong> #{html_escape(subject)}</p>

      <div style="border: 1px solid #ccc; padding: 15px; margin-top: 20px; background: #f9f9f9;">
        <h3 style="margin-top: 0;">Message:</h3>
        <p style="white-space: pre-wrap;">#{html_escape(message)}</p>
      </div>

      <hr style="border: 1px solid #000; margin: 20px 0;" />
      <p style="color: #666; font-size: 12px;">
        Sent from ayomos.com contact form<br/>
        Reply directly to this email to respond to #{name}
      </p>
    </div>
    """)
    |> text_body("""
    New Contact Form Submission
    ===========================

    From: #{name}
    Email: #{email}
    Subject: #{subject}

    Message:
    #{message}

    ---
    Sent from ayomos.com contact form
    Reply directly to this email to respond to #{name}
    """)
    |> Mailer.deliver()
  end

  # Validation helpers
  defp validate_required(errors, value, _field, message) when value in ["", nil] do
    [message | errors]
  end
  defp validate_required(errors, _value, _field, _message), do: errors

  defp validate_email(errors, email) do
    # Simple email validation
    if email != "" and not String.match?(email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/) do
      ["Please enter a valid email address" | errors]
    else
      errors
    end
  end

  defp validate_length(errors, value, _field, _min, _max) when value in ["", nil], do: errors
  defp validate_length(errors, value, field, min, max) do
    len = String.length(value)
    cond do
      len < min -> ["#{String.capitalize(field)} must be at least #{min} characters" | errors]
      len > max -> ["#{String.capitalize(field)} must be less than #{max} characters" | errors]
      true -> errors
    end
  end

  defp validate_no_urls(errors, value, _field) do
    # Check for suspicious URL patterns (common in spam)
    url_pattern = ~r/(https?:\/\/|www\.|\.com\/|\.net\/|\.org\/|bit\.ly|tinyurl)/i
    if String.match?(value, url_pattern) do
      ["Links are not allowed in messages for security reasons" | errors]
    else
      errors
    end
  end

  # Simple HTML escape function
  defp html_escape(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&#39;")
  end
end
