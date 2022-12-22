defmodule TimeGif do
  use Application

  @moduledoc """
  Starts the `TimeGif` application
  """

  @impl true
  def start(_type, _args) do
    TimeGif.Supervisor.start_link(name: TimeGif.Supervisor)
  end
end
