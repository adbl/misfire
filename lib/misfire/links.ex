defmodule Misfire.Links do
  @base_uri "http://localhost:4000/api"

  def value(activity_id, value_id \\ "") do
    "#{@base_uri}/activities/#{activity_id}/values/#{value_id}"
  end
end