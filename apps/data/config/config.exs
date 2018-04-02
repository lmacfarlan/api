use Mix.Config


config :data,
  ecto_repos: [Data.Repo],
  cassandra: [
    nodes: [
      "<server address address>:<your server port>"
    ]
  ]

config :data, Data.Repo,
  adapter:    Ecto.Adapters.Postgres,
  username:   "db user",
  password:   "",
  hostname:   "localhost",
  database:   "oddcarl",
  pool_size:  10
