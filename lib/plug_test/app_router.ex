defmodule AppRouter do
  import Plug.Connection
  use Plug.Router

  plug :match
  plug :dispatch

  get "/metrics" do
    send_resp(conn, 200, "world")
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
