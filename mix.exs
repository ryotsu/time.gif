defmodule TimeGif.Mixfile do
  use Mix.Project

  def project do
    [
      app: :time_gif,
      version: "1.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {TimeGif, []},
      applications: [:cowboy, :ranch, :httpoison, :jason],
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:cowboy, "~> 2.8"},
      {:jason, "~> 1.4"},
      {:httpoison, "~> 2.0"}
    ]
  end
end
