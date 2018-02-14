defmodule Data.Providers.Movie do
  alias Data.Cassandra

  @keyspace "ea28b544e93cff97e42b770e"
  @table_name "movie_list"

  def get(movie_id: movie_id) do
    statement = "SELECT movie_id, movie_title, popularity, ingest_date, ingested_info FROM #{@keyspace}.#{@table_name} WHERE movie_id = ? LIMIT 1;"
    values    = [
      {"text", movie_id}
    ]
    Cassandra.execute(statement, values)
  end

  def all() do
    statement = "SELECT movie_id, movie_title, popularity, ingest_date, ingested_info FROM #{@keyspace}.#{@table_name};"
    Cassandra.execute(statement, [])
  end
end
