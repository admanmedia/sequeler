require Logger

defmodule Sequeler do
  @moduledoc """

    Hints, snippets and stuff:

    Setup db for code:

    ```
      create database testdb;
      grant all privileges on testdb.* to 'testuser'@'localhost' identified by
          'testpassword' with grant option;
      flush privileges;
    ```

  """


  use Application

  def start(_type, _args) do
    # supervise our plug
    import Supervisor.Spec, warn: false

    # start emysql if not started and add pool
    :emysql.add_pool(:db, Application.get_env(:sequeler, :db_opts))

    children = [Plug.Adapters.Cowboy.child_spec(:http, Sequeler.Plug, [])]

    opts = [strategy: :one_for_one, name: Sequeler.Supervisor]
    res = Supervisor.start_link(children, opts)

    res
  end

  @version Sequeler.Mixfile.project[:version]
  def version, do: @version
end


defmodule Sequeler.Plug do

  @moduledoc """
    Main Plug, this is the router. Centralizes url signature validation too.
  """

  import Plug.Conn
  use Plug.Router
  alias Cipher, as: C

  plug Plug.Logger
  plug :match
  plug :dispatch

  # handy to have them around
  @k Application.get_env(:sequeler, :key_phrase) |> C.generate_key
  @i Application.get_env(:sequeler, :iv_phrase) |> C.generate_iv

  def init(_) do
    ["Running ", :bright, "Sequeler", :reset,
      " on ", :green, "http://localhost:4000", :reset]
    |> IO.ANSI.format(true) |> Logger.info
  end

  get "/query" do

    path = "/query?" <> conn.query_string
    valid? = C.validate_signed_url(path, @k, @i)

    conn = case valid? do
      true -> conn |> fetch_params |> Sequeler.Controller.query
      false -> resp(conn, 401, "Unauthorized")
    end

    send_resp conn
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
