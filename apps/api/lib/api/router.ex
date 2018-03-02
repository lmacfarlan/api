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
end
