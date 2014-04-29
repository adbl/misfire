defmodule Misfire.Model.Value do
  alias __MODULE__
  alias Misfire.Model.Value.Data

  defstruct id: nil :: String.t, timestamp: nil :: String.t, value: nil

  def list(activity_id) do
    case Data.read_values(activity_id) do
      nil -> nil
      values -> for value <- values, do: struct(Value, value)
    end
  end

  def update(values, activity_id) do
    Data.update_values(values, activity_id)
  end
end

defmodule Misfire.Model.Value.Data do
  import Misfire.Model.Data
  alias Misfire.JsonCodec

  @values "values/"

  def read_values(activity_id) do
    case read_file("#{@values}#{activity_id}") do
      {:error, _}   -> nil
      {:ok, <<>>}   -> []         # empty, list
      {:ok, binary} ->
        binary |> JSON.decode! |> Dict.fetch!("values")
        |> Enum.map &%{ id: Dict.fetch!(&1, "id"),
                        timestamp: Dict.fetch!(&1, "timestamp"),
                        value: Dict.fetch!(&1, "value") }
    end
  end

  def update_values(values, activity_id) do
    # TODO version control
    File.write! cwd_path("#{@values}#{activity_id}"), serialize(values)
  end

  defp serialize(values) do
    [ values: Enum.map(values, &JsonCodec.value_to_json/1)] |> JSON.encode!
  end
end
