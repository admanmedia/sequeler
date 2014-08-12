defmodule Sequeler do
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
   use Plug.Router
   
   plug :match
   plug :dispatch

   def start_link() do
     ["Running ", :bright, "Sequeler", :reset, 
       " on ", :green, "http://localhost:4000", :reset]
     |> IO.ANSI.format(true) |> IO.puts

     Plug.Adapters.Cowboy.http __MODULE__, []
   end

   get "/hello" do
     result = :emysql.execute :db, "select sleep(2)"
     IO.puts( inspect result )
     send_resp(conn, 200, "world")
   end

   match _ do
     send_resp(conn, 404, "oops")
   end
end
