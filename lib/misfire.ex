defmodule Misfire do
  use Application.Behaviour

  # See http://elixir-lang.org/docs/stable/Application.Behaviour.html
  # for more information on OTP Applications
  def start(_type, _args) do
    port = 4000
    # TODO configure hostname
    uri = "http://localhost:#{port}"
    { :ok, _ } = Plug.Adapters.Cowboy.http(Misfire.AppRouter, [], port: port)
    IO.puts "Running Misfire with Cowboy on #{uri}"
    Misfire.Supervisor.start_link
  end
end
