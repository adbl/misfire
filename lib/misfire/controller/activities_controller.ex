defmodule Misfire.Controller.Activities do
  use Misfire.Controller

  alias Misfire.JsonCodec
  alias Misfire.Model.Activity
  alias Misfire.Links

  @links [ "activities.values":
           [ href: Links.value("{activities.id}"), type: "values"],
           "activities.current_value":
           [ href: Links.value("{activities.id}", "{activities.current_value}"),
             type: "values"]
         ]

  def options(conn) do
    respond(conn, @ct_text, 200, "GET")
  end

  def get(conn) do
    respond(conn, @ct_json, 200,
            Activity.list |> to_json |> JSON.encode!)
  end

  defp to_json(activities) do
    # TODO: refactor to use one iteration starting from "template" map
    linked_values = for %Activity{ current_value: val } <- activities,
                    val != nil, do: JsonCodec.value_to_json(val)
    activities_json = Enum.map(activities, &activity_to_json/1)
    # linked = not Enum.empty?(linked_values)
    # && [ linked: [ values: linked_values ] ] || []

    [ links: @links,
      activities: activities_json,
      # ] ++ linked
      linked: [ values: linked_values ] ]
  end

  # TOOD: move to JsonCodec?
  defp activity_to_json(%Activity{ id: id, name: name, type: type,
                                   current_value: value }) do
    links = value && [ links: [ current_value: value.id ] ] || []
    [ id: id, name: name, type: type] ++ links
  end
end
