defmodule Misfire.Links do
  # TODO JSON.encode escapes / -> \\/ for some reason, seems to look ok when
  # decoded though
  @base_uri "http://localhost:4000"

  def value(measure_id, value_id \\ "") do
    "#{@base_uri}/measures/#{measure_id}/values/#{value_id}"
  end
end