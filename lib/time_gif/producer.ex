defmodule TimeGif.Producer do
  @moduledoc """
  Producer for TimeGif

  Produces the image to be sent
  """

  use GenServer, restart: :permanent

  alias TimeGif.Encoder.GIF
  alias TimeGif.Encoder.LZW
  alias TimeGif.Digits
  alias TimeGif.Manager

  def start_link(offset) do
    GenServer.start_link(__MODULE__, offset)
  end

  @spec subscribe(pid, pid) :: binary
  def subscribe(producer, pid) do
    GenServer.call(producer, {:subscribe, pid})
  end

  @impl true
  def init(offset) do
    base =
      "GIF89a" <>
        GIF.screen_descriptor(132, 28, 0) <>
        GIF.color_table() <>
        GIF.application_extension(0)

    frame = get_next_frame(offset)

    Process.send_after(self(), :next_frame, 1000)
    Process.send_after(self(), :send_frame, 1000)

    Process.send(Manager, {:producer, offset, self()}, [])

    {:ok, %{base: base, frame: frame, clients: [], offset: offset}}
  end

  @impl true
  def handle_call({:subscribe, pid}, _from, %{clients: clients} = state) do
    clients = [pid | clients]
    Process.monitor(pid)

    {:reply, state.base <> state.frame, %{state | clients: clients}}
  end

  @impl true
  def handle_info(:next_frame, %{offset: offset} = state) do
    Process.send_after(self(), :next_frame, 1000)

    frame = get_next_frame(offset)

    {:noreply, %{state | frame: frame}}
  end

  @impl true
  def handle_info(:send_frame, %{clients: clients} = state) do
    Process.send_after(self(), :send_frame, 1000)

    for client <- clients do
      send(client, state.frame)
    end

    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    clients = List.delete(state.clients, pid)

    {:noreply, %{state | clients: clients}}
  end

  @spec get_next_frame(integer) :: binary
  defp get_next_frame(offset) do
    GIF.graphic_control_ext(1, 100) <>
      GIF.image_descriptor(132, 28) <>
      get_frame_data(offset)
  end

  @spec get_frame_data(integer) :: binary
  defp get_frame_data(offset) do
    Time.utc_now()
    |> Time.add(offset)
    |> Time.to_string()
    |> String.split(".")
    |> Digits.get_image_data()
    |> LZW.compress(2)
  end
end
