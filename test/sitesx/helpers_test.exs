Code.require_file "../../test_helper.exs", __ENV__.file

defmodule Sitesx.HelpersTest do
  use Sitesx.Support.ConnCase, async: true

  import Sitesx.Helpers

  test "basic without a ensured DNS record" do
    conn = get build_conn(), "/"
    conn = Map.put conn, :host, "subdomain4.example.com"
    assert "http://example.com/?sub=subdomain4" == subdomain_url(conn, "home.index")
  end

  test "basic with a ensured DNS record" do
    conn = get build_conn(), "/"
    conn = Map.put conn, :host, "subdomain1.example.com"
    assert "http://subdomain1.example.com/" == subdomain_url(conn, "home.index")
  end

  test "subdomain without a ensured DNS record" do
    conn = get build_conn(), "/"
    assert "http://example.com/?sub=subdomain2" == subdomain_url("subdomain2", conn, "home.index")
  end

  test "subdomain with a ensured DNS record" do
    conn = get build_conn(), "/"
    assert "http://subdomain3.example.com/" == subdomain_url("subdomain3", conn, "home.index")
  end

  test "query string without a ensured DNS record" do
    conn = get build_conn(), "/"
    assert "http://example.com/release/place-holder?some=1&sub=subdomain4&thing=2" == subdomain_url("subdomain4", conn, "entry.release:place-holder", some: "1", thing: "2")
  end

end
