defmodule Data.Providers.Movie do
  alias Data.Cassandra

  require Logger

  @keyspace "ea28b544e93cff97e42b770e"
  @table_name "movie_list_pop_sorted"

  @doc """
  Gets all movies for a given `ingest_date`, filtering out `adult` and `video` entries.

  When using paging_state, ensure that you use the same `ingest_date` based on the previous run's results,
  otherwise you risk the cursor being applied to the incorrect result set.

  ## Parameters
    - ingest_date: Date that movie info was ingested, denotes how recent movie data is
    - page_size: number of results per page to return
    - paging_state: cursor for finding the next page of results
    - retry_count: counter for how many days in the past to continue looking for results from current `ingest_date`

  ## Examples
      iex> alias Data.Providers.Movie
      Data.Providers.Movie

      iex> Movie.all(~D[2018-03-02], 10, nil)

  """
  def all(ingest_date, page_size, paging_state, retry_count \\ 7) do
    IO.inspect {:paging_state, paging_state}
    statement = "SELECT movie_id, movie_title, popularity, ingest_date, adult, video FROM #{@keyspace}.#{@table_name} where ingest_date = ?;"
    values = [
      {"date", ingest_date}
    ]
    results =
      if paging_state == nil do
        Cassandra.execute(statement, values, page_size: page_size)
      else
        Cassandra.execute(statement, values, page_size: page_size, paging_state: paging_state)
      end

    # If we didn't find anything, go back one day until we do
    # or we run out of retries
    case results do
      {:error, reason} ->
        results
      {:ok, movies} ->
        case Enum.empty?(movies) && retry_count > 0 do
          true ->
            all(Date.add(ingest_date, -1), page_size, paging_state, retry_count - 1)
          false ->
            results
        end
    end
  end

  def reject_adult_and_video(%Xandra.Page{} = page) do
    # ** NOTE ** By passing the Xandra.Page struct through
    # an Enum function, it is being realized, if you remove
    # the reject, you must call Enum.to_list on the page to
    # return the results as a realized list
    page
    |> Enum.reject(fn(r) ->
        Map.get(r, "adult") || Map.get(r, "video")
      end)
  end
end