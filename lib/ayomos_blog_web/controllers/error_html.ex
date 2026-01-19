defmodule AyomosBlogWeb.ErrorHTML do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on HTML requests.

  See config/config.exs.
  """
  use AyomosBlogWeb, :html

  embed_templates "error_html/*"

  # Custom error pages
  def render("404.html", assigns) do
    render("404.html", assigns)
  end

  def render("429.html", assigns) do
    render("429.html", assigns)
  end

  def render("500.html", assigns) do
    render("500.html", assigns)
  end

  # Fallback for other errors
  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
