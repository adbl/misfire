defmodule PlugTest.Measures do
  # TODO: defrecordp?
  defrecord Measure, id: nil, name: nil, type: :nil, current_value: nil do
    # type: event | 2-state (on/off) | numeric | multi-state
    record_type id: String.t, name: String.t, type: :event|:duration
  end

  defrecord Value, id: nil, timestamp: nil, value: nil do
    record_type id: String.t, timestamp: String.t, value: Integer
  end

  def read_measures do
    File.ls!("#{cwd_path(@measures)}") |> Enum.map(&read_measure/1)
  end

  def read_measure(measure_id) do
    case read_file("#{@measures}#{measure_id}") do
      {:error, _} -> nil
      {:ok, binary} ->
        measure = measure_from_json(measure_id, binary)
        measure |> read_current_value |> measure.current_value
    end
  end

  defp measure_from_json(id, binary) do
    json = JSON.decode!(binary)
    Measure[id: id, name: Dict.fetch!(json, "name"),
                               type: Dict.fetch!(json, "type")]
  end

  def read_current_value(Measure[id: id]) do
    (read_values(id) || []) |> Enum.at(-1)
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

  def update_values(values, measure_id) do
    # TODO version control
    File.write! cwd_path("#{@values}#{measure_id}"), values_to_json(values)
  end

  defp values_to_json(values) do
    [values: values |> Value.to_keywords
    ] |> JSON.encode!
  end

  defp cwd_path(file), do: "#{File.cwd!}/data/#{file}"

  defp read_file(localpath), do: File.read cwd_path(localpath)
end
