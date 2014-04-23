defmodule Misfire.Model.Value do
  alias Misfire.Model.Value.Data

  defrecord Value, id: nil, timestamp: nil, value: nil do
    record_type id: String.t, timestamp: String.t, value: Integer
  end

  def list(activity_id) do
    case Data.read_values(activity_id) do
      nil -> nil
      values -> lc value inlist values, do: Value.new(value)
    end
  end

  def update(values, activity_id) do
    Data.update_values(values, activity_id)
  end
end

defmodule Misfire.Model.Value.Data do
  import Misfire.Model.Data

  @values "values/"

  def read_values(activity_id) do
    case read_file("#{@values}#{activity_id}") do
      {:error, _}   -> nil
      {:ok, <<>>}   -> []         # empty, list
      {:ok, binary} -> JSON.decode!(binary)
                       |> Dict.fetch!("values")
                       |> Enum.map(&Keyword.from_enum/1)
    end
  end

  def update_values(values, activity_id) do
    # TODO version control
    File.write! cwd_path("#{@values}#{activity_id}"), values_to_json(values)
  end

  defp values_to_json(values) do
    [values: values |> Enum.map(&(&1.to_keywords))]
    |> JSON.encode!
  end
end
