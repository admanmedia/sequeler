require Logger, as: L

defmodule SequelerTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias Sequeler.Plug, as: P

  @opts P.init([])

  test "performs query" do
    L.warn "TODO"

    # query with no data gets empty
    url = "/query"
    conn = conn(:get, url)
    conn = P.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert Jazz.decode!(conn.resp_body) == ""

    # create data

    # query over data gets data
  end
end
