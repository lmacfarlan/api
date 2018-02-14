defmodule Data.Cassandra do
  require Logger

  @seconds_per_day (24 * 60 * 60)

  def start_link do
    config = Application.get_env(:data, :cassandra)
    nodes = Keyword.get(config, :nodes)
    Logger.info(fn -> "Trying to connect to Cassandra nodes: #{inspect nodes}" end)
    {:ok, conn} = Xandra.start_link([
      nodes: nodes,
    ])
    Agent.start_link(fn -> %{conn: conn} end, name: __MODULE__)
  end

  @doc """
  Prepare a CQL statement.
  """
  def prepare(statement) do
    Xandra.prepare(get_conn(), statement)
  end

  @doc """
  Executes either a prepared statement, or a string containing valid CQL.

  This function can be passed parameters and options which are both keyword
  lists. Mainly, you will be interested in page_size and cursor parameters
  which allow you to define how many things you'll get back (up to that
  limit) and where to continue from in the stored datasets.
  """
  def execute(statement, params \\ [], opts \\ []) do
    Xandra.execute(get_conn(), statement, params, opts)
  end

  def to_cassandra_date(dt) do
    unix_time = DateTime.to_unix(dt)
    Kernel.trunc(unix_time / @seconds_per_day) + Kernel.trunc(:math.pow(2, 31))
  end
  def from_cassandra_date(date) do
    (date - Kernel.trunc(:math.pow(2, 31))) * @seconds_per_day
  end

  def get_conn, do: Agent.get(__MODULE__, &Map.get(&1, :conn))
end
