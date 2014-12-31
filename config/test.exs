use Mix.Config

config :sequeler, :key_phrase, "testingphrasesforencryption"
config :sequeler, :iv_phrase, "testingphrasesforencryption"

config :bottler, :servers, [server1: [public_ip: "123.123.123.123"],
                             server2:  [public_ip: "123.123.123.123"]]

config :sequeler, :db_opts, [ size: 50, user: 'testuser',
      password: 'testpassword', database: 'testdb', encoding: :utf8 ]
