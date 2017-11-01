defmodule TimeGif do
  @moduledoc """
  Documentation for TimeGif.
  """

  def start(_type, _args) do
    TimeGif.Super.start_link()
  end
end
