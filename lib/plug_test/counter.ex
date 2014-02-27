defmodule PlugTest.Counters do
  defrecord Counter, id: nil, name: nil, type: :counter, values: nil do
    # type: counter | 2-state (on/off)
    # numeric
    # multi-state
    # TODO: use cases of each
    record_type id: String.t, name: String.t, type: :counter, values: [Value]
  end

  defrecord Value, id: nil, timestamp: nil, value: nil do
    record_type id: String.t, timestamp: String.t, value: Integer
  end

  # TODO JSON.encode escapes / -> \\/ for some reason, seems to look ok when
  # decoded though
  @base_uri "http://..."
  @counters "counters/"
  @values "values/"

  def read_counters do
    File.ls!("#{cwd_path(@counters)}") |> Enum.map(&read_counter/1)
  end

  def read_counter(counter_id, read_values? \\ false) do
    values = if read_values?, do: read_values(counter_id)
    case read_file("#{@counters}#{counter_id}") do
      {:error, _} -> nil
      {:ok, binary} ->
        counter = counter_from_json(counter_id, binary)
        counter.values(values)
    end
  end

  defp counter_from_json(id, binary) do
    json = JSON.decode!(binary)
    Counter[id: id, name: Dict.fetch!(json, "name"),
                               type: Dict.fetch!(json, "type")]
  end

  def read_values(counter_id) do
    case read_file("#{@values}#{counter_id}") do
      {:error, _} -> nil
      {:ok, binary} -> values_from_json(binary)
    end
  end

  defp values_from_json(binary) do
    json = JSON.decode!(binary)
    Dict.fetch!(json, "values") |> Enum.map &value_from_json/1
  end

  # TODO keep private and use new_value-isch with type checks from interface
  def value_from_json(json, id \\ nil) do
    # TODO check for nil and assert empty w/Dict.pop
    id = id || json["id"]
    timestamp = json["timestamp"]
    value = json["value"]
    Value[id: id, timestamp: timestamp, value: value]
  end

  def values_to_json(values) do
    values
    |> Enum.map(&value_to_kv/1)
    |> encode_json_values
  end

  def update_values(values, counter_id) do
    # TODO version control
    File.write! cwd_path("#{@values}#{counter_id}"), values_to_json(values)
  end

  defp value_to_kv(Value[id: id, timestamp: timestamp, value: value]) do
    [id: id, timestamp: timestamp, value: value]
  end

  defp encode_json_values(kvs) do
    JSON.encode! [values: kvs]
  end

  def counters_to_json(counters) do
    counters
    |> Enum.map(&counter_to_kv/1)
    |> encode_json_counters
  end

  defp counter_to_kv(Counter[id: id, name: name, type: type]) do
    [id: id, name: name, type: type]
  end

  defp encode_json_counters(kvs) do
    JSON.encode! [links: ["counters.values":
                          "#{@base_uri}/counters/{counters.id}/values"],
                  counters: kvs]
  end


  defp cwd_path(file), do: "#{File.cwd!}/data/#{file}"

  defp read_file(localpath), do: File.read cwd_path(localpath)
end
