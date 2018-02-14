use Mix.Config


config :data,
  ecto_repos: [Data.Repo],
  cassandra: [
    nodes: [
      "10.0.1.59:9042"
    ]
  ]

config :data, Data.Repo,
  adapter:    Ecto.Adapters.Postgres,
  username:   "wess",
  password:   "",
  hostname:   "localhost",
  database:   "oddcarl",
  pool_size:  10
