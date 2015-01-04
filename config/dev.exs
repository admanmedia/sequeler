use Mix.Config

config :sequeler, :key_phrase, "testingphrasesforencryption"
config :sequeler, :iv_phrase, "testingphrasesforencryption"

config :bottler, :servers, [server1: [user: "myuser", ip: "1.1.1.1"],
                            server2: [user: "myuser", ip: "1.1.1.2"]]

config :bottler, :mixfile, Sequeler.Mixfile

config :sequeler, :db_opts, [ size: 50, user: 'testuser',
      password: 'testpassword', database: 'testdb', encoding: :utf8 ]
