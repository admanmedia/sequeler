require Logger, as: L

defmodule SequelerTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias Sequeler.Plug, as: P
  import TestHelper
  alias Cipher, as: C

  @opts P.init([])

  test "validates signature for query" do
    sql = "show tables" |> URI.encode_www_form # harmless
    url = "/query?sql=" <> sql

    # query with no signature gets 401
    conn = get(url, P, @opts)
    assert conn.status == 401
    # query with bad signature gets 401
    conn = get(url <> "&signature=badash", P, @opts)
    assert conn.status == 401
    # signed query gets 200
    conn = url |> C.sign_url(k,i) |> get(P, @opts)
    assert conn.status == 200
  end

  test "performs query" do
    L.warn "TODO"

    # prepare table
    :emysql.execute :db, "drop table if exists test"
    :emysql.execute :db, "create table test (i int) engine=memory"

    # prepare query
    sql = "select * from test" |> URI.encode_www_form
    url = "/query?sql=" <> sql |> C.sign_url(k,i)

    # query with no data gets empty
    conn = get(url, P, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert get_resp_header(conn,"content-type") == "application/json"
    assert Jazz.decode!(conn.resp_body) == []

    # create data
    :emysql.execute :db, "insert into test (i) values (1)"

    # query over data gets data
    conn = get(url, P, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert get_resp_header(conn,"content-type") == "application/json"
    assert Jazz.decode!(conn.resp_body) == [ [i: 1] ]
  end
end
