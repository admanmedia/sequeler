

defmodule Sequeler do
  @moduledoc """

    Hints, snippets and stuff:

    On a new mariadb install, set root password:

    ```
      use mysql;
      update user set password=PASSWORD("first_root_pass") where User='root';
      flush privileges;
    ```

    Then setup db for code:

    ```
      create database testdb;
      grant all privileges on testdb.* to 'testuser'@'localhost' identified by
          'testpassword' with grant option;
      flush privileges;
    ```

  """


  use Application

  def start(_type, _args) do

    # add emysql pool
    :emysql.add_pool(:db, [ size: 50,
      user: 'testuser', password: 'testpassword',
      database: 'testdb', encoding: :utf8 ])

    # supervise our plug
    import Supervisor.Spec, warn: false

    children = [ worker(Sequeler.Plug, []) ]

    opts = [strategy: :one_for_one, name: Sequeler.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule Sequeler.Plug do
  import Plug.Conn
  import Plug.Logger
  use Plug.Router

  plug :match
  plug :dispatch

  def start_link() do
    ["Running ", :bright, "Sequeler", :reset,
      " on ", :green, "http://localhost:4000", :reset]
    |> IO.ANSI.format(true) |> IO.puts

    Plug.Adapters.Cowboy.http __MODULE__, [] # 100 acceptors by default
  end

  get "/query" do
    sql = "select sleep(2)"

    case :emysql.execute(:db,sql) do
      {:result_packet, num, _, _, data} ->
          json = Jazz.encode! data
      _ -> json = "{}"
    end

    send_resp(conn, 200, json)
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
