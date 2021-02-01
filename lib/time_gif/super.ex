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
      {TimeGif.Producer, :ok}
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
