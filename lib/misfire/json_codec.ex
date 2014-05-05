defmodule Misfire.JsonCodec do
  alias Misfire.Model.Value

  def value_to_json(%Value{ id: id, timestamp: timestamp, value: value }) do
    [ id: id, timestamp: timestamp, value: value ]
  end

  def value_from_json(json, new_id) do
    # TODO check for nil and assert empty w/Dict.pop
    id = new_id || json["id"]
    timestamp = json["timestamp"]
    value = json["value"]
    # TODO Validate using Value.new
    %Value{id: id, timestamp: timestamp, value: value}
  end
end