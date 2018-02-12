use Mix.Config

config :data, ecto_repos: [Data.Repo,]

config :data, Data.Repo,
  adapter:    Ecto.Adapters.Postgres,
  username:   "wess",
  password:   "",
  hostname:   "localhost",
  database:   "oddcarl",
  pool_size:  10
