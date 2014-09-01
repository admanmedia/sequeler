require IEx
require Logger, as: L

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
  alias Cipher, as: C

  plug :match
  plug :dispatch

  # handy to have them around
  @k Application.get_env(:sequeler, :key_phrase) |> C.generate_key
  @i Application.get_env(:sequeler, :iv_phrase) |> C.generate_iv

  def start_link() do
    ["Running ", :bright, "Sequeler", :reset,
      " on ", :green, "http://localhost:4000", :reset]
    |> IO.ANSI.format(true) |> IO.puts

    Plug.Adapters.Cowboy.http __MODULE__, [] # 100 acceptors by default
  end

  get "/query" do

    path = "/query?" <> conn.query_string

    case C.validate_signed_url(path, @k, @i) do
      true -> send_resp(conn, 200, "Authorized")
      false -> send_resp(conn, 401, "Unauthorized")
    end
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
