defmodule PlugTest.AppRouter do
  require IEx
  alias Plug.Conn
  alias PlugTest.Measures
  alias PlugTest.JsonParser

  import PlugTest.JsonCodec
  import Plug.Connection
  use Plug.Router

  plug :cors
  plug :match
  plug :dispatch

  @ct_json "application/vnd.api+json"
  @ct_text "text/plain"

  @msg_201 "201 Created"
  @msg_400 "400 Bad Request"            # check rfc 2616/jsonapi.org
  @msg_404 "404 Not Found"
  @msg_415 "415 Unsupported Media Type" # check rfc 2616/jsonapi.org

  def cors(conn, _) do
    conn
    |> put_resp_header("Access-Control-Allow-Origin", "*")
    |> put_resp_header("Access-Control-Allow-Headers",
                       "Origin, Content-Type, Accept")
  end

  options "/measures"  do
    respond(conn, @ct_text, 200, "GET")
  end

  get "/measures"  do
    respond(conn, @ct_json, 200, Measures.read_measures |> measures_to_json)
  end

  options "/measures/:id/values" do
    case read_values(conn, id) do
      { :ok, _ } -> respond(conn, @ct_text, 200, "GET,POST")
      { :error, conn } -> conn
    end
  end

  get "/measures/:id/values" do
    case read_values(conn, id) do
      { :ok, values } ->
        respond(conn, @ct_json, 200, values_to_json(values))
      { :error, conn } -> conn
    end
  end

  post "/measures/:id/values" do
    case read_values(conn, id) do
      { :ok, values } ->
        case post_json(conn, json_value(length(values)+1)) do
          { :ok, conn, value } ->
            Measures.update_values(values ++ [value], id) # abstraction leak
            # TODO: include created record, and location?
            respond(conn, @ct_text, 201, @msg_201)
          { :error, conn } -> conn
        end
      { :error, conn } -> conn
    end
  end

  defp read_values(conn, measure_id) do
    case Measures.read_values(measure_id) do
      nil -> { :error, respond(conn, @ct_text, 404, @msg_404) }
      values -> { :ok, values }
    end
  end

  defp json_value(new_id) do
    fn (json) ->
         case json["values"] do
           # TODO use pop and assert rest is empty Dict
           [value] -> Measures.value_from_json(value, new_id)
           _ -> :error
         end
    end
  end

  defp post_json(Conn[req_headers: req_headers] = conn, parse_fun) do
    # TODO handle utf-8 or encoding
    case req_headers["content-type"] do
      @ct_json -> decode_json(conn, parse_fun)
      _ -> { :error, respond(conn, @ct_text, 415, @msg_415) }
    end
  end

  defp decode_json(conn, parse_fun) do
    case JsonParser.decode(conn) do
      { :ok, conn, json } -> parse_json(conn, json, parse_fun)
      # TODO: nicer error message, json encoded?
      { :error, conn } -> { :error, respond(conn, @ct_text, 400, @msg_400) }
    end
  end

  defp parse_json(conn, json, parse_fun) do
    case parse_fun.(json) do
      # TODO: nicer error message, json encoded?
      :error -> { :error, respond(conn, @ct_text, 400, @msg_400) }
      parsed -> { :ok, conn, parsed }
    end
  end

  match _ do
    respond(conn, @ct_text, 404, @msg_404)
  end

  defp respond(conn, ct, code, body) do
    conn |> put_resp_content_type(ct) |> send_resp(code, body)
  end
end
