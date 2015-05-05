use Mix.Config

config :sequeler, :key_phrase, "testingphrasesforencryption"
config :sequeler, :iv_phrase, "testingphrasesforencryption"

config :sequeler, :db_opts, [ size: 5, user: 'root',
      password: 'dbPASS', database: 'rita_development', encoding: :utf8 ]

config :sequeler, :db_remote_forrest_opts, [ size: 5, user: 'root',
      password: 'dbPASS', database: 'rita_development', encoding: :utf8 ]
