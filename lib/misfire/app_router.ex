defmodule Misfire.AppRouter do
  import Plug.Connection
  use Plug.Router

  use Misfire.Controller

  alias Misfire.Controller.Activities
  alias Misfire.Controller.Values

  plug :cors
  plug :match
  plug :dispatch

  # TODO only for dev
  def cors(conn, _) do
    conn
    |> put_resp_header("Access-Control-Allow-Origin", "*")
    |> put_resp_header("Access-Control-Allow-Headers",
                       "Origin, Content-Type, Accept")
  end

  # TODO support POST (need to add an empty values file)
  options "/api/activities" do
    Activities.options(conn)
  end
  get "/api/activities" do
    Activities.get(conn)
  end

  options "/api/activities/:id/values" do
    Values.options conn, activity: id
  end
  get "/api/activities/:id/values" do
    Values.get conn, activity: id
  end
  post "/api/activities/:id/values" do
    Values.post conn, activity: id
  end

  match _ do
    respond(conn, @ct_text, 404, @msg_404)
  end
end
