defmodule AddressInput.MixProject do
  use Mix.Project

  def project do
    [
      app: :address_input,
      version: "0.2.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      package: package(),

      # Docs
      name: "AddressInput",
      description: "Loads and queries address metadata derived from the libaddressinput dataset.",
      source_url: "https://github.com/nkezhaya/address_input",
      homepage_url: "https://github.com/nkezhaya/address_input",
      docs: docs()
    ]
  end

  defp docs do
    [
      main: "AddressInput",
      extras: ["README.md"]
    ]
  end

  def application do
    []
  end

  defp package do
    [
      files:
        ~w(lib/address_input.ex lib/address_input priv .formatter.exs mix.exs README.md LICENSE),
      licenses: ["MIT", "CC-BY-4.0"],
      links: %{
        "Github" => "https://github.com/nkezhaya/address_input",
        "Data source" => "https://github.com/google/libaddressinput",
        "Data license" => "https://creativecommons.org/licenses/by/4.0/"
      }
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
    ]
  end

  defp deps do
    [
      {:req, "~> 0.5", only: [:dev, :test]},
      {:lazy_html, "~> 0.1", only: [:dev, :test]},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false, warn_if_outdated: true}
    ]
  end

  defp aliases do
    [
      precommit: [
        "compile --warning-as-errors",
        "deps.unlock --unused",
        "format",
        "credo --strict",
        "test"
      ]
    ]
  end
end
