use Mix.Config

config :sequeler, :key_phrase, "unomasuno"
config :sequeler, :iv_phrase, "memomimamamemima"

servers = [
  bardeen: [ip: '176.58.102.177', private_ip: '192.168.164.110']
]

config :bottler, :params, [servers: servers,
                           remote_user: "epdp" ]

config :sequeler, :db_opts, [ size: 5, user: 'epdp',
      password: 'elpulgardb', database: 'rita_production', encoding: :utf8,
      host: servers[:conrad][:private_ip]]

config :sequeler, :db_forrest_opts, [ size: 5, user: 'epdp',
      password: 'elpulgardb', database: 'rita_production', encoding: :utf8,
      host: servers[:bardeen][:private_ip]]
