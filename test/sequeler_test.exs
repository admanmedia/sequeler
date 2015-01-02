alias Sequeler.Helpers, as: H

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
    # prepare table
    H.query :db, "drop table if exists test"
    H.query :db, "create table test (i int, a varchar(20)) engine=memory"

    # prepare query
    sql = "select * from test" |> URI.encode_www_form
    url = "/query?sql=" <> sql |> C.sign_url(k,i)

    # query with no data gets empty
    conn = get(url, P, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert get_resp_header(conn,"content-type") == ["application/json"]
    assert Jazz.decode!(conn.resp_body) == []

    # create data
    H.query :db, "insert into test (i,a) values (1,'hey')"

    # query over data gets data
    conn = get(url, P, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert get_resp_header(conn,"content-type") == ["application/json"]
    assert Jazz.decode!(conn.resp_body) == [ [1,"hey"] ]
  end

  test "performs check_sync_status" do
    # prepare table
    for db <- [:db, :db_remote_forrest] do
      :emysql.execute db, "drop table if exists test"
      :emysql.execute db, "create table test (i int, updated_ts bigint(20)) engine=memory"
    end

    # prepare query
    url = "/check_sync_status?table=test" |> C.sign_url(k,i)

    # query with no data gets false, could not check anything
    conn = get(url, P, @opts)
    assert conn.status == 200
    assert get_resp_header(conn,"content-type") == ["application/json"]
    assert Jazz.decode!(conn.resp_body) == %{"valid" => false}

    # create data, the same everywhere
    for db <- [:db, :db_remote_forrest] do
      :emysql.execute db, "insert into test (i,updated_ts) values (1,123456789012345678)"
    end

    # query over data gets true
    conn = get(url, P, @opts)
    assert Jazz.decode!(conn.resp_body) == %{"valid" => true}

    # change remote one
    :emysql.execute :db_remote_forrest,
                "insert into test (i,updated_ts) values (1,123456789012345679)"

    # query gets false, different updated_ts
    conn = get(url, P, @opts)
    assert Jazz.decode!(conn.resp_body) == %{"valid" => false}

    # add the same to local
    :emysql.execute :db,
                "insert into test (i,updated_ts) values (1,123456789012345679)"

    # query over data gets true again
    conn = get(url, P, @opts)
    assert Jazz.decode!(conn.resp_body) == %{"valid" => true}

  end
end
