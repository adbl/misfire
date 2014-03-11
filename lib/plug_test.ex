defmodule PlugTest do
  use Application.Behaviour

  # See http://elixir-lang.org/docs/stable/Application.Behaviour.html
  # for more information on OTP Applications
  def start(_type, _args) do
    port = 4000
    # TODO configure hostname
    uri = "http://localhost:#{port}"
    { :ok, _ } = Plug.Adapters.Cowboy.http(PlugTest.AppRouter, [], port: port)
    IO.puts "Running MyPlug with Cowboy on #{uri}"
    PlugTest.Supervisor.start_link
  end
end
