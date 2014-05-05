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

  alias Plug.Conn

  def respond(conn, ct, code, body, headers \\ []) do
    Enum.reduce(headers, conn,
                fn { k, v }, conn -> Conn.put_resp_header(conn, k, v) end)
    |> Conn.put_resp_content_type(ct) |> Conn.send_resp(code, body)
  end

end