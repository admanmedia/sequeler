use Mix.Config

config :sequeler, :key_phrase, "testingphrasesforencryption"
config :sequeler, :iv_phrase, "testingphrasesforencryption"

config :sequeler, :db_opts, [ size: 50, user: 'testuser',
      password: 'testpassword', database: 'testdb', encoding: :utf8 ]
