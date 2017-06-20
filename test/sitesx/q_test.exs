Code.require_file "../../test_helper.exs", __ENV__.file

defmodule Sitesx.QTest do
  use Sitesx.Support.ConnCase, async: true

  alias Sitesx.Q

  # test "To ensure all of dns record, which stores boolean to database" do
  # end

  test "Find a record from Plug.Conn" do
    conn = build_conn()
    conn = Map.put conn, :host, "subdomain1.example.com"
    conn = get conn, "/"

    q = %Ecto.Query{} = Q.site conn
    assert Repo.one(q).name == "subdomain1"
  end

  test "Find a record from subdomain name" do
    q = %Ecto.Query{} = Q.site "subdomain1"
    assert Repo.one(q).name == "subdomain1"
  end

  test "Get a sitesx record from model which relates as 1:N between one of model and `Sitesx`" do
    conn = build_conn()
    conn = Map.put conn, :host, "subdomain1.example.com"
    conn = get conn, "/"

    %Ecto.Query{} = Q.with_site(Sitesx.Support.Entry, conn)
    # assert Repo.one(q).name == "subdomain1"
  end


end
