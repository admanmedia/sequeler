use Mix.Config

config :sequeler, :key_phrase, "unomasuno"
config :sequeler, :iv_phrase, "memomimamamemima"

servers = [
<<<<<<< Updated upstream
  bardeen: [public_ip: '176.58.102.177', private_ip: '192.168.164.110']
]

config :bottler, :servers, [conrad: servers[:conrad]]
=======
  bardeen: [ip: '176.58.102.177', private_ip: '192.168.164.110'],
  conrad: [ip: '176.58.117.234', private_ip: '192.168.165.72']
]

config :bottler, :params, [servers: [bardeen: servers[:bardeen]] ,
                               remote_user: "epdp" ]
>>>>>>> Stashed changes

config :sequeler, :db_opts, [ size: 5, user: 'epdp',
      password: 'elpulgardb', database: 'rita_production', encoding: :utf8,
      host: servers[:bardeen][:private_ip]]

config :sequeler, :db_remote_opts, [ size: 5, user: 'epdp',
      password: 'elpulgardb', database: 'rita_production', encoding: :utf8,
      host: servers[:conrad][:private_ip]]
