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
        case handle_post_json(conn, json_value(new_value_id)) do
          { :ok, {conn, value} } ->
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
           [value] -> { :ok, JsonCodec.value_from_json(value, new_id) }
           _ -> :error
         end
    end
  end
end