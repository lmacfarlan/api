defmodule Data.Providers.Vote do
  @keyspace "ea28b544e93cff97e42b770e"
  @table_name "votes"

  alias Data.Cassandra

  def get(user_id: user_id) do
    statement = "SELECT user_id, movie_id, vote, vote_time FROM #{@keyspace}.#{@table_name} WHERE user_id = ?;"
    Cassandra.execute(statement, [{"text", user_id}])
  end

  def insert(params \\ %{}) do
    statement = "INSERT INTO #{@keyspace}.#{@table_name} (user_id, movie_id, vote, vote_time) VALUES (?, ?, ?, ?);"
    values    = [
      {"text", Map.get(params, "user_id")},
      {"text", Map.get(params, "movie_id")},
      {"boolean", Map.get(params, "vote")},
      {"timestamp", DateTime.to_unix(DateTime.utc_now(), :millisecond)}
    ]
    Cassandra.execute(statement, values)
  end
end
