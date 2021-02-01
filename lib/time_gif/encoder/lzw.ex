defmodule TimeGif.Encoder.LZW do
  @moduledoc """
  LZW Compression
  """

  @type codes :: [{integer, integer}]

  @doc """
  Compress image data using LZW compression
  """
  @spec compress([integer], integer) :: binary | :error
  def compress(indices, min_code) when min_code >= 2 do
    # Initialize the code table and the next code index
    {table, next} = init_table(min_code)

    # Store first index of the image data as index_buffer
    [buffer | indices] = indices

    # First code size = LZW min code size + 1
    code_width = min_code + 1

    # Send a clear code at the start of the code stream
    init_code = [{table.clear, min_code + 1}]

    codes =
      indices
      |> encode(init_code, table, [buffer], next, code_width)
      |> Enum.reduce(<<>>, fn {code, width}, acc ->
        <<code::size(width), acc::bitstring>>
      end)

    # Pad the codestream and reverse it
    codes =
      codes
      |> pad_bits
      |> :binary.decode_unsigned(:little)
      |> :binary.encode_unsigned(:big)

    <<min_code, chunkify(codes)::bitstring, 0>>
  end

  def compress(_, _), do: :error

  @spec encode([integer], codes, map, [integer], integer, integer) :: codes
  defp encode(indices, codes, table, buf, next, width) when next == 4096 do
    # GIF format allows maximum code of 4095. If we want to use a new code,
    # we have to clear out the old codes. This can be done by sending a clear
    # code to the code stream and reinitializing the code table
    {table, next} = init_table(table.min_code)
    codes = [{table.clear, width} | codes]
    encode(indices, codes, table, buf, next, table.min_code + 1)
  end

  defp encode([k | indices], codes, table, buf, next, width) do
    # Token to search for in the code table or store as buffer
    token = [k | buf]

    case Map.fetch(table, token) do
      # If token is in the table, use token as the next buffer
      {:ok, _} ->
        encode(indices, codes, table, token, next, width)

      # If token isn't in the table, add token to the table with the next code.
      # Send the code for the current buffer to the code stream.
      # Use k as the next buffer and loop.
      :error ->
        table = Map.put(table, token, next)
        new_code = Map.fetch!(table, buf)
        codes = [{new_code, width} | codes]
        next = next + 1

        width =
          if :math.pow(2, width) < next do
            width + 1
          else
            width
          end

        encode(indices, codes, table, [k], next, width)
    end
  end

  defp encode([], codes, table, buf, _next, width) do
    new_code = Map.fetch!(table, buf)
    codes = [{table.end, width}, {new_code, width} | codes]
    codes |> Enum.reverse()
  end

  @spec init_table(integer) :: {map, integer}
  defp init_table(min_code) do
    # Final index of colours in global colour table
    # Total colours = 2^(min_code)
    colour_count = round(:math.pow(2, min_code)) - 1

    # Initialize colour table
    # Fill colour indices as keys and values
    # and Add code for clear and end
    table =
      0..colour_count
      |> Enum.reduce(%{}, fn x, acc ->
        Map.put(acc, [x], x)
      end)
      |> Map.put(:clear, colour_count + 1)
      |> Map.put(:end, colour_count + 2)
      |> Map.put(:min_code, min_code)

    # Return the table and the index where next code starts
    {table, colour_count + 3}
  end

  @spec pad_bits(binary) :: binary
  defp pad_bits(block) do
    null_bits = 8 - rem(bit_size(block), 8)

    case null_bits == 8 do
      true -> block
      false -> <<0::size(null_bits), block::bitstring>>
    end
  end

  # Break data blocks into sizes of 255 byes max
  @spec chunkify(binary, binary) :: binary
  defp chunkify(data, combined \\ "")

  defp chunkify(<<data::bytes-size(255), rest::bitstring>>, combined) do
    chunkify(rest, combined <> <<255, data::bitstring>>)
  end

  defp chunkify(data, combined) do
    combined <> <<byte_size(data), data::bitstring>>
  end
end
