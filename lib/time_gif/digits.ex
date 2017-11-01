defmodule TimeGif.Digits do
  @moduledoc """
  Represent the digits
  """

  @zero  [[1, 1, 1],
          [1, 0, 1],
          [1, 0, 1],
          [1, 0, 1],
          [1, 1, 1]]

  @one   [[1, 1, 0],
          [0, 1, 0],
          [0, 1, 0],
          [0, 1, 0],
          [1, 1, 1]]

  @two   [[1, 1, 1],
          [0, 0, 1],
          [1, 1, 1],
          [1, 0, 0],
          [1, 1, 1]]

  @three [[1, 1, 1],
          [0, 0, 1],
          [0, 1, 1],
          [0, 0, 1],
          [1, 1, 1]]

  @four  [[1, 0, 1],
          [1, 0, 1],
          [1, 1, 1],
          [0, 0, 1],
          [0, 0, 1]]

  @five  [[1, 1, 1],
          [1, 0, 0],
          [1, 1, 1],
          [0, 0, 1],
          [1, 1, 1]]

  @six   [[1, 1, 1],
          [1, 0, 0],
          [1, 1, 1],
          [1, 0, 1],
          [1, 1, 1]]

  @seven [[1, 1, 1],
          [0, 0, 1],
          [0, 0, 1],
          [0, 0, 1],
          [0, 0, 1]]

  @eight [[1, 1, 1],
          [1, 0, 1],
          [1, 1, 1],
          [1, 0, 1],
          [1, 1, 1]]

  @nine  [[1, 1, 1],
          [1, 0, 1],
          [1, 1, 1],
          [0, 0, 1],
          [0, 0, 1]]

  @colon [[0, 0, 0],
          [0, 1, 0],
          [0, 0, 0],
          [0, 1, 0],
          [0, 0, 0]]

  @spec get_image_data([String.t]) :: [integer]
  def get_image_data([time | _decimals]) do
    time
    |> String.graphemes
    |> Enum.map(&get_indices/1)
    |> Enum.reduce([[]], &padding/2)
    |> Enum.map(fn x ->
         Enum.map(x, fn y -> y |> List.duplicate(4) end)
         |> List.duplicate(4)
         |> List.flatten
    end)
    |> List.flatten
  end

  @spec get_indices(String.t) :: [[integer]]
  defp get_indices(digit) do
    case digit do
      "0" -> @zero
      "1" -> @one
      "2" -> @two
      "3" -> @three
      "4" -> @four
      "5" -> @five
      "6" -> @six
      "7" -> @seven
      "8" -> @eight
      "9" -> @nine
      ":" -> @colon
    end
  end

  @spec padding([[integer]], [[integer]]) :: [[integer]]
  defp padding(digit, [[]]) do
    digit = [[0, 0, 0]] ++ digit ++ [[0, 0, 0]]
    Enum.map(digit, fn i -> [0] ++ i ++ [0] end)
  end

  defp padding(digit, image) do
    digit = [[0, 0, 0]] ++ digit ++ [[0, 0, 0]]

    Enum.zip(digit, image)
    |> Enum.map(fn {a, b} ->
      b ++ a ++ [0]
    end)
  end
end
