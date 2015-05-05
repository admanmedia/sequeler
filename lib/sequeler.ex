require Logger

defmodule Sequeler do
  @moduledoc """
    Main Application module.
  """

  use Application

  def start(_type, _args) do
    # supervise our plug
    import Supervisor.Spec

    # start emysql if not started and add pool
    :emysql.add_pool(:db, Application.get_env(:sequeler, :db_opts))
    :emysql.add_pool(:db_remote,
                     Application.get_env(:sequeler, :db_remote_opts))

    # respond to harakiri restarts
    tmp_path = Application.get_env(:sequeler, :tmp_path, "tmp") |> Path.expand
    Harakiri.add %{ paths: ["#{tmp_path}/restart"],
                    app: :sequeler,
                    action: :restart }

    children = [ Plug.Adapters.Cowboy.child_spec(:http, Sequeler.Plug, []),
                 worker(Task, [Sequeler,:alive_loop,[]]) ]

    opts = [strategy: :one_for_one, name: Sequeler.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @version Sequeler.Mixfile.project[:version]
  def version, do: @version

  @doc """
    Tell the world outside we are alive
  """
  def alive_loop do
    tmp_path = Application.get_env(:sequeler, :tmp_path, "tmp") |> Path.expand
    :os.cmd 'touch #{tmp_path}/alive'
    :timer.sleep 5_000
    alive_loop
  end
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
    if Mix.env != :test do
      ["Running ", :bright, "Sequeler", :reset,
        " on ", :green, "http://localhost:4000", :reset]
      |> IO.ANSI.format(true) |> Logger.info
    end
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

  get "/check_sync_status" do

    path = "/check_sync_status?" <> conn.query_string
    valid? = C.validate_signed_url(path, @k, @i)

    conn = case valid? do
      true -> conn |> fetch_params |> Sequeler.Controller.check_sync_status
      false -> resp(conn, 401, "Unauthorized")
    end

    send_resp conn
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
