defmodule Api.Router do
  use Pilot.Router

  require Logger
  import Pilot.Responses, only: [json: 3]

  plug Api.Plug.ValidateContentType
  plug :match

  get "/movies" do
    cursor = Map.get(conn.params, "cursor", nil)
    idate =
      conn.params
      |> Map.get("ingest_date", nil)
      |> ingest_date()
    case decode_cursor(cursor) do
      {:ok, decoded} ->
        case Data.Providers.Movie.all(idate, 100, decoded) do
          {:ok, %Xandra.Page{} = page} ->
            results = Data.Providers.Movie.reject_adult_and_video(page)
            json(conn, :ok, %{data: results, cursor: Base.encode64(page.paging_state)})
          {:error, reason} ->
            json(conn, 500, %{error: "unknown error fetching list: #{inspect(reason)}"})
        end
      {:error, reason} ->
        json(conn, :bad_request, %{error: reason})
    end
  end

  get "/recommendations" do
    conn
    |> Map.get(:params, %{})
    |> Map.get(:cursor)
    |> decode_cursor()
    |> case do
      {:ok, decoded_cursor} ->
        [paging_state: decoded_cursor]
        |> Data.Providers.Recommendations.all()
        |> handle_recommendations_resp()
        |> (&json(conn, Map.get(&1, :status), &1)).()
      {:error, reason} ->
        status =
          400
        resp =
          Map.new()
          |> Map.put(:error, reason)
          |> Map.put(:status, status)
        json(conn, status, resp)
    end
  end

  post "/vote" do
    user_id =
      conn
      |> get_req_header("X-API-Token")
    case user_id do
      "" -> json(conn, :bad_request, %{error: "No API token provided"})
      uid ->
        case Data.Providers.Vote.insert(conn.params) do
          {:ok, _} -> json(conn, :created, %{data: %{success: true}})
          {:error, reason} -> json(conn, :bad_request, %{error: "#{inspect(reason)}"})
        end
    end
  end

  match _ do
    conn
    |> put_resp_content_type("application/json")
    |> json(:not_found, %{error: "not found"})
  end

  defp ingest_date(nil), do: Date.utc_today()
  defp ingest_date(ingest_date) do
    case Date.from_iso8601(ingest_date) do
      {:ok, i_date} ->
        i_date
      {:error, reason} ->
        Logger.debug(fn -> "Unable to parse `ingest_date`, using today's date because #{inspect reason}" end)
        Date.utc_today()
    end
  end

  defp decode_cursor(nil), do: {:ok, nil}
  defp decode_cursor(cursor) do
    case Base.decode64(cursor) do
      {:ok, decoded} -> {:ok, decoded}
      :error -> "Invalid cursor: #{inspect(cursor)}"
    end
  end

  defp handle_recommendations_resp({:ok, %Xandra.Page{} = page}) do
    paging_state =
      Map.get(page, :paging_state)
    Map.new()
    |> put_encoded_cursor(paging_state)
    |> Map.put(:recommendations, Enum.to_list(page))
    |> Map.put(:status, 200)
  end

  defp handle_recommendations_resp({:error, reason}) do
    Map.new()
    |> Map.put(:error, reason)
    |> Map.put(:status, 400)
  end

  defp handle_recommendations_resp(resp) do
    Logger.debug(fn -> "Unknown recommendations response: #{inspect(resp)}" end)
    Map.new()
    |> Map.put(:error, "Unknown error occurred when fetching recommendations")
    |> Map.put(:status, 500)
  end

  defp put_encoded_cursor(map, nil), do: map
  defp put_encoded_cursor(map, cursor) do
    case Base.encode64(cursor) do
      {:ok, encoded_cursor} ->
        Map.put(map, :cursor, encoded_cursor)
      {:error, reason} ->
        Logger.debug(fn -> "Error while encoding cursor: #{inspect(reason)}" end)
        map
    end
  end
end
