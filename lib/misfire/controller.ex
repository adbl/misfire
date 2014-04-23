defmodule Misfire.Controller do
  defmacro __using__(_) do
    quote do
      import Misfire.Controller
      @ct_json "application/vnd.api+json"
      @ct_text "text/plain"

      @msg_201 "201 Created"
      @msg_400 "400 Bad Request"            # check rfc 2616/jsonapi.org
      @msg_404 "404 Not Found"
      @msg_415 "415 Unsupported Media Type" # check rfc 2616/jsonapi.org
    end
  end

  import Plug.Connection

  def respond(conn, ct, code, body, headers \\ []) do
    Enum.reduce(headers, conn,
                fn { k, v }, conn -> put_resp_header(conn, k, v) end)
    |> put_resp_content_type(ct) |> send_resp(code, body)
  end

end