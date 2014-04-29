defmodule Misfire.Model.Activity do
  alias __MODULE__
  alias Misfire.Model.Value
  alias Misfire.Model.Activity.Data

  defstruct id: nil :: String.t, name: nil :: String.t, type: nil :: :event|:duration, current_value: nil :: Value.t

  def list do
    Data.list |> Enum.map(&read/1)
  end

  def read(id) do
    case Data.read(id) do
      nil -> nil
      data -> %Activity{ struct(Activity, data) |
                         id: id, current_value: List.last(Value.list(id)) }
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
        %{ name: Dict.fetch!(json, "name"),
           type: Dict.fetch!(json, "type") }
    end
  end
end
