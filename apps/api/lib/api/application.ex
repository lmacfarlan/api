defmodule Api.Application do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Api.Endpoint, [])
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Api.Supervisor)
  end

  def stop(_state) do
    :ok
  end
end
