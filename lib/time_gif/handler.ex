defmodule TimeGif.Handler do
  @moduledoc """
  Handler for streaming time gifs
  """

  alias TimeGif.Producer

  @spec init(map, list) :: {:cowboy_loop, map, list}
  def init(req, state) do
    req =
      :cowboy_req.stream_reply(
        200,
        %{
          "content-type" => "image/gif",
          "connection" => "keep-alive",
          "content-transfer-encoding" => "binary",
          "expires" => "0"
        },
        req
      )

    data = Producer.subscribe()
    :cowboy_req.stream_body(data, :nofin, req)

    {:cowboy_loop, req, state}
  end

  @spec info(binary, map, list) :: {:ok, map, list}
  def info(msg, req, state) when is_binary(msg) do
    :cowboy_req.stream_body(msg, :nofin, req)
    {:ok, req, state}
  end
end
