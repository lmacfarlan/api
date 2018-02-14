defmodule Data.Providers.Vote do
  @keyspace "ea28b544e93cff97e42b770e"
  @table_name "votes"

  alias Data.Cassandra

  def get(user_id: user_id) do
    statement = "SELECT user_id, movie_id, vote FROM #{@keyspace}.#{@table_name} WHERE user_id = ?;"
    Cassandra.execute(statement, [{"text", user_id}])
  end

  def insert(params \\ %{}) do
    statement = "INSERT INTO #{@keyspace}.#{@table_name} (user_id, movie_id, vote) VALUES (?, ?, ?);"
    values    = [
      {"text", params[:user_id]},
      {"text", params[:movie_id]},
      {"boolean", params[:vote]}
    ]
    Cassandra.execute(statement, values)
  end
end
