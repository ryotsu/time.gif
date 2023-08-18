defmodule TimeGif.Handler do
  @moduledoc """
  Handler for streaming time gifs
  """

  alias TimeGif.Manager

  @spec init(map, list) :: {:cowboy_loop, map, list}
  def init(req, state) do
    req =
      :cowboy_req.stream_reply(
        200,
        %{
          "Content-Type" => "image/gif",
          "connection" => "keep-alive",
          "content-transfer-encoding" => "binary",
          "expires" => "0",
          "Cache-Control" => "no-cache, no-store, no-transform"
        },
        req
      )

    offset =
      case req |> :cowboy_req.headers() |> Map.fetch("x-real-ip") do
        {:ok, ip} -> get_offset_from_ip(ip)
        _ -> 0
      end

    data = Manager.subscribe(offset)

    :cowboy_req.stream_body(data, :nofin, req)

    {:cowboy_loop, req, state}
  end

  @spec info(binary, map, list) :: {:ok, map, list}
  def info(msg, req, state) when is_binary(msg) do
    :cowboy_req.stream_body(msg, :nofin, req)
    {:ok, req, state}
  end

  defp get_offset_from_ip(ip) do
    case HTTPoison.get("http://ip-api.com/json/#{ip}?fields=offset") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body |> Jason.decode!() |> Map.get("offset")

      _ ->
        0
    end
  end
end
