defmodule AyomosBlogWeb.Helpers.Markdown do
  @moduledoc """
  Helper functions for rendering Markdown content.
  """

  @doc """
  Converts Markdown text to HTML.
  Returns a Phoenix.HTML.safe tuple for direct rendering in templates.
  """
  def to_html(nil), do: {:safe, ""}
  def to_html(""), do: {:safe, ""}

  def to_html(markdown) when is_binary(markdown) do
    case Earmark.as_html(markdown, %Earmark.Options{
      code_class_prefix: "language-",
      smartypants: true,
      breaks: true
    }) do
      {:ok, html, _} -> {:safe, html}
      {:error, html, _} -> {:safe, html}
    end
  end
end
