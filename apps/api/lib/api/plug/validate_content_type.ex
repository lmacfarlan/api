defmodule Api.Plug.ValidateContentType do
  use Plug.Builder
  import Plug.Conn

  plug Plug.Parsers,
    parsers: [:json],
    pass: [],
    json_decoder: Poison

  @methods ~w(POST PUT PATCH)

  def init(opts), do: opts

  def call(%{method: method} = conn, opts) when method in @methods do
    conn
    |> super(opts)
    |> response_conn_with(List.first(get_req_header(conn, "content-type")))
  rescue e ->
    unsupported_media_type(conn, "Unsupported media type #{Map.get(e, :media_type, "")}")
  end
  def call(conn, opts), do: super(conn, opts)

  def response_conn_with(conn, nil) do
    unsupported_media_type(conn, "Request is missing Content-Type")
  end
  def response_conn_with(conn, _content_type), do: conn

  def unsupported_media_type(conn, msg) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> send_resp(:unsupported_media_type, Poison.encode_to_iodata!(%{errors: %{details: msg}}))
    |> halt
  end
end
