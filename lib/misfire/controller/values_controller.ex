defmodule Misfire.Controller.Values do
  use Misfire.Controller

  alias Misfire.JsonCodec
  alias Misfire.Links
  alias Misfire.Model.Value

  def options(conn, [activity: id]) do
    case read_values(conn, id) do
      { :ok, _ } -> respond(conn, @ct_text, 200, "GET,POST")
      { :error, conn } -> conn
    end
  end

  def get(conn, [activity: id]) do
    case read_values(conn, id) do
      { :ok, values } ->
        respond(conn, @ct_json, 200, to_json(values))
      { :error, conn } -> conn
    end
  end

  def post(conn, [activity: id]) do
    case read_values(conn, id) do
      { :ok, values } ->
        # leaky abstraction
        new_value_id = length(values)+1
        case post_json(conn, json_value(new_value_id)) do
          { :ok, conn, value } ->
            # abstraction leak
            Value.update(values ++ [value], id)
            respond(conn, @ct_json, 201, to_json([value]),
                    [{"location", Links.value(id, new_value_id)}])
          { :error, conn } -> conn
        end
      { :error, conn } -> conn
    end
  end

  defp to_json(values) do
    [ values: Enum.map(values, &JsonCodec.value_to_json/1) ] |> JSON.encode!
  end

  defp read_values(conn, activity_id) do
    case Value.list(activity_id) do
      nil -> { :error, respond(conn, @ct_text, 404, @msg_404) }
      values -> { :ok, values }
    end
  end

  defp json_value(new_id) do
    fn (json) ->
         case json["values"] do
           # TODO use pop and assert rest is empty Dict
           [value] -> JsonCodec.value_from_json(value, new_id)
           _ -> :error
         end
    end
  end

  defp post_json(%Plug.Conn{req_headers: req_headers} = conn, parse_fun) do
    # TODO handle utf-8 or encoding
    case req_headers["content-type"] do
      @ct_json -> decode_json(conn, parse_fun)
      _ -> { :error, respond(conn, @ct_text, 415, @msg_415) }
    end
  end

  defp decode_json(conn, parse_fun) do
    case Misfire.JsonParser.decode(conn) do
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
end