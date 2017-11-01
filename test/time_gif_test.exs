defmodule TimeGifTest do
  use ExUnit.Case
  doctest TimeGif

  test "greets the world" do
    assert TimeGif.hello() == :world
  end
end
