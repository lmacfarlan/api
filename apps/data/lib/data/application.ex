defmodule Data.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Data.Repo, [])
    ]

    options = [
      strategy: :one_for_one,
      name:     Data.Supervisor
    ]

    Supervisor.start_link(children, options)
  end
end
