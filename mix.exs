defmodule TimeGif.Mixfile do
  use Mix.Project

  def project do
    [
      app: :time_gif,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {TimeGif, []},
      applications: [:cowboy, :ranch],
      extra_applications: [:logger],
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:cowboy, "~> 2.0"},
    ]
  end
end
