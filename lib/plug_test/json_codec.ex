defmodule PlugTest.JsonCodec do
  alias PlugTest.Measures.Measure
  alias PlugTest.Measures.Value

  # TODO JSON.encode escapes / -> \\/ for some reason, seems to look ok when
  # decoded though
  @base_uri "http://localhost:4000"
  @measures "measures/"
  @values "values/"

  @measure_links ["measures.values":
   [href: "#{@base_uri}/measures/{measures.id}/values", type: "values"],
   "measures.current_value":
   [href: "#{@base_uri}/measures/{measures.id}/values/" <>
      "{measures.current_value}", type: "values"]
  ]

  def measures_to_json(measures) do
    linked_values = measures
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

  def values_to_json(values) do
    [values: values |> Enum.map(&Value.to_keywords/1)
    ] |> JSON.encode!
  end
end