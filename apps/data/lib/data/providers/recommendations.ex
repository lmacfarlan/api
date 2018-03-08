defmodule Data.Providers.Recommendations do
  @moduledoc false

  require Logger

  alias Data.Cassandra

  @default_page_size 100
  @keyspace "ea28b544e93cff97e42b770e"
  @table_name "recommendations"

  @doc """
  Get all Recommendations

  ## Options

  This function accepts the following options:

    * `page_size` - (integer) number of results per page to return
    * `paging_state` - (binary) cursor for finding the next page of results

  """
  def all(opts \\ []) do
    query =
      select_all_query()
    params =
      []
    opts =
      default_opts()
      |> Keyword.merge(opts)
      # Filter out keywords with nil value
      |> Enum.filter(&!!elem(&1, 1))
    Cassandra.execute(query, params, opts)
  end

  def default_page_size, do: @default_page_size


  # Private


  defp default_opts, do: [page_size: @default_page_size]

  defp select_all_query, do: "SELECT * FROM #{@keyspace}.#{@table_name}"
end