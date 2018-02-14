defmodule Api.Router do
  use Pilot.Router

  import Pilot.Responses, only: [json: 3]

  plug Api.Plug.ValidateContentType
  plug :match

  get "/movies" do
    cursor = Map.get(conn.params, "cursor", nil)
    case decode_cursor(cursor) do
      {:ok, decoded} ->
        case Data.Providers.Movie.all(20, decoded) do
          {:ok, %Xandra.Page{} = page} ->
            json(conn, :ok, %{data: Enum.to_list(page), cursor: Base.encode64(page.paging_state)})
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

  defp decode_cursor(nil), do: {:ok, nil}
  defp decode_cursor(cursor) do
    case Base.decode64(cursor) do
      {:ok, decoded} -> {:ok, decoded}
      :error -> "Invalid cursor: #{inspect(cursor)}"
    end
  end
end
