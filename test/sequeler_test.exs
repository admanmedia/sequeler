require Logger, as: L

defmodule SequelerTest do
  use ExUnit.Case, async: true
  use Plug.Test

  setup_all do

    # add emysql pool
    L.info "Creating the pool..."
    :emysql.add_pool(:db, [ size: 50,
      user: 'testuser', password: 'testpassword',
      database: 'testdb', encoding: :utf8 ])

    on_exit fn ->
      L.info "Removing the pool..."
      :emysql.remove_pool :db
    end

    :ok
  end

  test "the pool" do
    :emysql.execute :db, "select sleep(2)"
  end
end
