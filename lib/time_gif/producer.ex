defmodule TimeGif.Producer do
  @moduledoc """
  Producer for TimeGif

  Produces the image to be sent
  """

  use GenServer, restart: :permanent

  alias TimeGif.Encoder.GIF
  alias TimeGif.Encoder.LZW
  alias TimeGif.Digits

  def start_link(:ok) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def subscribe do
    GenServer.call(__MODULE__, :subscribe)
  end

  def init(:ok) do
    base =
      "GIF89a" <>
        GIF.screen_descriptor(132, 28, 0) <>
        GIF.color_table() <>
        GIF.application_extension(0)

    frame = get_next_frame()

    Process.send_after(self(), :next_frame, 1000)
    Process.send_after(self(), :send_frame, 1000)

    {:ok, %{base: base, frame: frame, clients: []}}
  end

  def handle_call(:subscribe, {pid, _tag}, %{clients: clients} = state) do
    clients = [pid | clients]
    Process.monitor(pid)

    {:reply, state.base <> state.frame, %{state | clients: clients}}
  end

  def handle_info(:next_frame, state) do
    Process.send_after(self(), :next_frame, 1000)

    frame = get_next_frame()

    {:noreply, %{state | frame: frame}}
  end

  def handle_info(:send_frame, %{clients: clients} = state) do
    Process.send_after(self(), :send_frame, 1000)

    for client <- clients do
      send(client, state.frame)
    end

    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    clients = List.delete(state.clients, pid)

    {:noreply, %{state | clients: clients}}
  end

  @spec get_next_frame :: binary
  defp get_next_frame do
    GIF.graphic_control_ext(1, 100) <>
      GIF.image_descriptor(132, 28) <>
      get_frame_data()
  end

  @spec get_frame_data :: binary
  defp get_frame_data do
    Time.utc_now()
    |> Time.to_string()
    |> String.split(".")
    |> Digits.get_image_data()
    |> LZW.compress(2)
  end
end
