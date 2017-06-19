defmodule Sitesx.ErrorView do
  # import Sitesx.Support.Router.Helpers

  def render("404.html", _assigns) do
    "Page not found"
  end

  def render("500.html", _assigns) do
    "Internal server error"
  end

  def template_not_found(_template, _assigns) do
  end
end
