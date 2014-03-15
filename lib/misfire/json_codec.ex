defmodule Misfire.JsonCodec do
  alias Misfire.Measures.Measure
  alias Misfire.Measures.Value
  alias Misfire.Links

  @measure_links ["measures.values":
   [href: Links.value("{measures.id}"), type: "values"],
   "measures.current_value":
   [href: Links.value("{measures.id}", "{measures.current_value}"),
                type: "values"]
  ]

  def measures_to_json(measures) do
    linked_values = measures
    |> Enum.filter( &(not nil? Measure.current_value(&1)) )
    |> Enum.map( &(Measure.current_value(&1) |> Value.to_keywords) )

    measures_json = Enum.map measures, &current_value_link/1

    [links: @measure_links,
     measures: measures_json,
     linked: [values: linked_values]
    ] |> JSON.encode!
  end

  defp current_value_link(Measure[current_value: Value[id: id]] = measure) do
    measure
    |> Measure.to_keywords
    |> Dict.delete(:current_value)
    |> Dict.put(:links, [current_value: id])
  end

  defp current_value_link(Measure[current_value: nil] = measure) do
    # TODO anyting on jsonapi.org about missing relationship?
    measure
    |> Measure.to_keywords
    |> Dict.delete(:current_value)
  end

  def values_to_json(values) do
    [values: values |> Enum.map(&Value.to_keywords/1)
    ] |> JSON.encode!
  end
end