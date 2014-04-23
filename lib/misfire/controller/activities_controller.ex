defmodule Misfire.Controller.Activities do
  use Misfire.Controller

  import Misfire.JsonCodec
  alias Misfire.Model.Activity

  def options(conn) do
    respond(conn, @ct_text, 200, "GET")
  end

  def get(conn) do
    respond(conn, @ct_json, 200, Activity.list |> activities_to_json)
  end
end