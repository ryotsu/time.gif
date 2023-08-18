defmodule TimeGif.Manager do
  alias TimeGif.Producer

  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @spec subscribe(integer()) :: binary()
  def subscribe(offset) do
    GenServer.call(__MODULE__, {:subscribe, offset})
  end

  @impl true
  def init(_args) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:subscribe, offset}, {pid, _tag}, state) do
    producer =
      case Map.fetch(state, offset) do
        {:ok, producer} ->
          producer

        :error ->
          spec = {Producer, offset}
          {:ok, producer} = DynamicSupervisor.start_child(TimeSupervisor, spec)
          producer
      end

    data = Producer.subscribe(producer, pid)

    {:reply, data, state}
  end

  @impl true
  def handle_info({:producer, offset, pid}, state) do
    Process.monitor(pid)

    {:noreply, Map.put(state, offset, pid)}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state) do
    {:noreply, state}
  end
end
