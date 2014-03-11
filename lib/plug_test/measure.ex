defmodule PlugTest.Measures do
  defrecord Measure, id: nil, name: nil, type: :nil, values: nil do
    # type: event | 2-state (on/off)
    # numeric
    # multi-state
    # TODO: use cases of each
    record_type id: String.t, name: String.t, type: :event|:duration,
                               current_value: Value
  end

  defrecord Value, id: nil, timestamp: nil, value: nil do
    record_type id: String.t, timestamp: String.t, value: Integer
  end

  # TODO JSON.encode escapes / -> \\/ for some reason, seems to look ok when
  # decoded though
  @base_uri "http://localhost:4000"
  @measures "measures/"
  @values "values/"

  def read_measures do
    File.ls!("#{cwd_path(@measures)}") |> Enum.map(&read_measure/1)
  end

  def read_measure(measure_id) do
    case read_file("#{@measures}#{measure_id}") do
      {:error, _} -> nil
      {:ok, binary} ->
        measure = measure_from_json(measure_id, binary)
        read_values(measure_id)
        measure.current_value(value)
    end
  end

  defp measure_from_json(id, binary) do
    json = JSON.decode!(binary)
    Measure[id: id, name: Dict.fetch!(json, "name"),
                               type: Dict.fetch!(json, "type")]
  end

  def read_values(measure_id) do
    case read_file("#{@values}#{measure_id}") do
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

  def update_values(values, measure_id) do
    # TODO version control
    File.write! cwd_path("#{@values}#{measure_id}"), values_to_json(values)
  end

  defp value_to_kv(Value[id: id, timestamp: timestamp, value: value]) do
    [id: id, timestamp: timestamp, value: value]
  end

  defp encode_json_values(kvs) do
    JSON.encode! [values: kvs]
  end

  def measures_to_json(measures) do
    measures
    |> Enum.map(&measure_to_kv/1)
    |> encode_json_measures
  end

  defp measure_to_kv(Measure[id: id, name: name, type: type]) do
    [id: id, name: name, type: type, links: [values: id]]
  end

  defp encode_json_measures(kvs) do
    [links: ["measures.values":
             [href: "#{@base_uri}/measures/{measures.values}/values",
              type: "values"]],
     measures: kvs] |> JSON.encode!
  end


  defp cwd_path(file), do: "#{File.cwd!}/data/#{file}"

  defp read_file(localpath), do: File.read cwd_path(localpath)
end
