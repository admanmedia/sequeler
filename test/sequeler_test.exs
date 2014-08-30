require Logger, as: L

defmodule SequelerTest do
  use ExUnit.Case, async: true
  use Plug.Test

  test "the pool" do
    :emysql.execute :db, "select sleep(2)"
  end
end
