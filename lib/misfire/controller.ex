defmodule Misfire.Controller do
  @ct_json "application/vnd.api+json"
  @ct_text "text/plain"

  @msg_201 "201 Created"
  @msg_400 "400 Bad Request"            # check rfc 2616/jsonapi.org
  @msg_404 "404 Not Found"
  @msg_415 "415 Unsupported Media Type" # check rfc 2616/jsonapi.org

  defmacro __using__(_) do
    quote do
      import Misfire.Controller
      @ct_json unquote(@ct_json)
      @ct_text unquote(@ct_text)

      @msg_201 unquote(@msg_201)
      @msg_400 unquote(@msg_400)
      @msg_404 unquote(@msg_404)
      @msg_415 unquote(@msg_415)
    end
  end

  use Misfire.Macros
  alias Plug.Conn

  def respond(conn, ct, code, body, headers \\ []) do
    Enum.reduce(headers, conn,
                fn { k, v }, conn -> Conn.put_resp_header(conn, k, v) end)
    |> Conn.put_resp_content_type(ct) |> Conn.send_resp(code, body)
  end

  def handle_post_json(%Plug.Conn{} = conn, parsefn) do
    handle_post(conn, @ct_json, &JSON.decode/1, parsefn)
  end

  def handle_post(%Plug.Conn{} = conn, content_type, decodefn, parsefn) do
    conn
    |> post_content_type(content_type)
    |> if_ok(post_body())
    |> if_ok(post_decode(decodefn))
    |> if_ok(post_parse(parsefn))
  end

  def post_content_type(conn, content_type) do
    # TODO handle utf-8 or encoding
    case conn.req_headers["content-type"] do
      ^content_type -> { :ok, conn }
      _ -> { :error, respond(conn, @ct_text, 415, @msg_415) }
    end
  end

  def post_body(%Plug.Conn{adapter: { adapter, state }} = conn) do
    # TODO handle upload limit / failure
    { :ok, body, state } = adapter.stream_req_body(state, 1_000_000)
    { :done, state } = adapter.stream_req_body(state, 1_000_000)
    conn = %Plug.Conn{conn| adapter: {adapter, state}}
    { :ok, {conn, body} }
  end

  def post_decode({conn, body}, decodefn) do
    case decodefn.(body) do
      { :ok, decoded } -> { :ok, {conn, decoded} }
      # TODO: nicer error message, json encoded?
      _ -> { :error, respond(conn, @ct_text, 400, @msg_400) }
    end
  end

  def post_parse({conn, decoded}, parsefn) do
    case parsefn.(decoded) do
      { :ok, parsed } -> { :ok, {conn, parsed} }
      # TODO: nicer error message, json encoded?
      _ -> { :error, respond(conn, @ct_text, 400, @msg_400) }
    end
  end
end