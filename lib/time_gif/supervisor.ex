defmodule TimeGif.Supervisor do
  @moduledoc """
  Supervisor for producer
  """

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {TimeGif.Manager, :ok},
      {DynamicSupervisor, strategy: :one_for_one, name: TimeSupervisor}
    ]

    {:ok, _} = start_cowboy()

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp start_cowboy() do
    dispatch = :cowboy_router.compile(_: [{"/time.gif", TimeGif.Handler, []}])

    :cowboy.start_clear(
      :my_http_listener,
      [port: 8080],
      %{env: %{dispatch: dispatch}, idle_timeout: 24 * 60 * 60 * 1000}
    )
  end
end
