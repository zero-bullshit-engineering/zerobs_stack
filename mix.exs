defmodule ZerobsStack.MixProject do
  use Mix.Project

  def project do
    [
      app: :zerobs_stack,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ZerobsStack.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:fun_with_flags, "~> 1.4"},
      {:fun_with_flags_ui, "~> 0.7"},
      {:telemetry_metrics_prometheus_core, "~> 0.2.2"},
      {:telemetry_poller, "~> 0.4"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
