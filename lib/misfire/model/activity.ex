defmodule Misfire.Model.Activity do
  alias Misfire.Model.Value
  alias Misfire.Model.Activity.Data

  # TODO: defrecordp?
  defrecord Activity, id: nil, name: nil, type: :nil, current_value: nil do
    # type: event | 2-state (on/off) | numeric | multi-state
    record_type id: String.t, name: String.t, type: :event|:duration
  end

  def list do
    Data.list |> Enum.map(&read/1)
  end

  def read(id) do
    case Data.read(id) do
      nil -> nil
      data ->
        Activity.new([id: id, current_value: List.last(Value.list(id))] ++ data)
    end
  end
end

defmodule Misfire.Model.Activity.Data do
  import Misfire.Model.Data

  @activities "activities/"

  def list do
    File.ls!("#{cwd_path(@activities)}")
  end

  def read(activity_id) do
    case read_file("#{@activities}#{activity_id}") do
      {:error, _}   -> nil
      {:ok, binary} ->
        json = JSON.decode!(binary)
        [name: Dict.fetch!(json, "name"), type: Dict.fetch!(json, "type")]
    end
  end
end
