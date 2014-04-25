defmodule Misfire.JsonParser do
  def decode(%Plug.Conn{adapter: { adapter, state }} = conn) do
    # TODO handle upload limit
    { :ok, body, state } = adapter.stream_req_body(state, 1_000_000)
    { :done, state } = adapter.stream_req_body(state, 1_000_000)
    conn = %{conn| adapter: {adapter, state}}
    case JSON.decode(body) do
      { :ok, json } -> { :ok, conn, json }
      _ -> { :error, conn }
    end
  end
end