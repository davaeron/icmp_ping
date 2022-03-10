defmodule IcmpPing.MixProject do
  use Mix.Project

  def project do
    [
      app: :icmp_ping,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # static analysis tools
      {:credo, "~> 1.6.0", only: [:dev, :test], runtime: false}
      # {:dialyxir, "~> 1.1.0", only: :dev, runtime: false},
      # {:licensir, "~> 0.4.2", only: :dev, runtime: false},
      # {:ex_doc, "~> 0.20.2", only: :dev, runtime: false},

      # # testing tools
      # {:mox, "~> 0.5", only: :test},
      # {:excoveralls, "~> 0.11.1", only: :test}
    ]
  end
end
