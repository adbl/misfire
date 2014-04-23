defmodule Misfire.JsonCodec do
  alias Misfire.Model.Activity.Activity
  alias Misfire.Model.Value.Value
  alias Misfire.Links

  @activity_links ["activities.values":
   [href: Links.value("{activities.id}"), type: "values"],
   "activities.current_value":
   [href: Links.value("{activities.id}", "{activities.current_value}"),
                type: "values"]
  ]

  def activities_to_json(activities) do
    linked_values = activities
    |> Enum.filter( &(not nil? Activity.current_value(&1)) )
    |> Enum.map( &(Activity.current_value(&1) |> Value.to_keywords) )

    activities_json = Enum.map activities, &current_value_link/1

    [links: @activity_links,
     activities: activities_json,
     linked: [values: linked_values]
    ] |> JSON.encode!
  end

  defp current_value_link(Activity[current_value: Value[id: id]]
                          = activity) do
    activity
    |> Activity.to_keywords
    |> Dict.delete(:current_value)
    |> Dict.put(:links, [current_value: id])
  end

  defp current_value_link(Activity[current_value: nil] = activity) do
    # TODO anyting on jsonapi.org about missing relationship?
    activity
    |> Activity.to_keywords
    |> Dict.delete(:current_value)
  end

  def values_to_json(values) do
    [values: values |> Enum.map(&Value.to_keywords/1)
    ] |> JSON.encode!
  end

  def value_from_json(json, new_id) do
    # TODO check for nil and assert empty w/Dict.pop
    id = new_id || json["id"]
    timestamp = json["timestamp"]
    value = json["value"]
    Value[id: id, timestamp: timestamp, value: value]
  end
end