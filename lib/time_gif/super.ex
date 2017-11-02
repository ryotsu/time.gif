defmodule TimeGif.Super do
  @moduledoc """
  Supervisor for producer
  """

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(TimeGif.Producer, [], restart: :permanent)
    ]

    {:ok, _} = start_cowboy()

    supervise(children, strategy: :one_for_one)
  end

  defp start_cowboy() do
    dispatch = :cowboy_router.compile([
      _: [{"/", TimeGif.Handler, []}]
    ])

    :cowboy.start_clear(:my_http_listener,
      [port: 8080],
      %{env: %{dispatch: dispatch}}
    )
  end
end
