defmodule AyomosBlogWeb.ErrorJSONTest do
  use AyomosBlogWeb.ConnCase, async: true

  test "renders 404" do
    assert AyomosBlogWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert AyomosBlogWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
