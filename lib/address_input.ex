defmodule AddressInput do
  @moduledoc """
  High-level API for address metadata derived from the
  [libaddressinput](https://github.com/google/libaddressinput) dataset.

  The module loads a JSON dataset from `priv/metadata.json` (bundled with the
  application) and exposes convenience functions for looking up normalized
  [Country](`AddressInput.Country`) and [Subregion](`AddressInput.Subregion`)
  structs.

  ## Primary entry points

  - `countries/0` returns all available countries sorted by name. Each country
    includes parsed subregions.
  - `get_country/1` returns a single country by ISO 3166-1 alpha-2 code (case
    insensitive), or `nil` if it is not present.

  ## Country fields

  A [Country](`AddressInput.Country`) includes:

  - `id` - ISO 3166-1 alpha-2 code.
  - `name` - localized display name from the dataset.
  - `default_language` - language code used for labels.
  - `required_fields` - list of required address components as atoms, derived
    from the dataset codes (`N`, `O`, `A`, `D`, `C`, `S`, `Z`, `X`).
  - `subregion_type`, `sublocality_type`, `postal_code_type` - label hints.
  - `postal_code_regex` - compiled regex for validating postal codes.
  - `address_format` - parsed formatting template from the dataset (`fmt`).
  - `local_address_format` - parsed local formatting template (`lfmt`) when present.
  - `subregions` - list of [Subregion](`AddressInput.Subregion`) entries.

  A [Subregion](`AddressInput.Subregion`) includes `id`, `iso_code`, and `name`.

  ## Example

      iex> AddressInput.get_country("US")
      %AddressInput.Country{
        id: "US",
        name: "UNITED STATES",
        default_language: "en",
        required_fields: [:address, :sublocality, :region, :postal_code],
        sublocality_type: "city",
        subregion_type: "state",
        postal_code_type: "zip",
        postal_code_regex: ~r/(\\d{5})(?:[ -](\\d{4}))?/,
        address_format: [{:field, :name}, :newline, ...],
        local_address_format: nil,
        subregions: [
          %AddressInput.Subregion{id: "AK", iso_code: "AK", name: "Alaska"},
          ...
        ]
      }
      "US"

  """
  alias __MODULE__.Country

  @type token ::
          {:field, Country.field()}
          | {:text, String.t()}
          | :newline

  @type address_format :: [token()]

  @doc """
  Returns the list of available countries as [Country](`AddressInput.Country`) structs.
  """
  @spec countries() :: [Country.t()]
  def countries do
    {_, sorted} = country_tree()
    sorted
  end

  @doc """
  Returns a [Country](`AddressInput.Country`) by ISO 3166-1 alpha-2 country code.

  Returns `nil` when the country is not found.
  """
  @spec get_country(String.t()) :: Country.t() | nil
  def get_country(country) do
    # "ZZ" seems to be a blank country
    key = String.upcase(country)
    {tree, _} = country_tree()

    if :gb_trees.is_defined(key, tree) do
      :gb_trees.get(key, tree)
    end
  end

  defp country_tree do
    :persistent_term.get(:address_input_countries)
  end

  @doc """
  Returns `{:ok, postal_code}` if the postal code matches the expected format
  for the given country. Otherwise, returns `:error`. The provided country must
  be either a `%Country{}` or a string that resolves to one.
  """
  @spec parse_postal_code(String.t(), String.t() | Country.t()) :: {:ok, String.t()} | :error
  def parse_postal_code(postal_code, country) do
    case do_parse_postal_code(postal_code, country) do
      [result] -> {:ok, result}
      nil -> :error
    end
  end

  defp do_parse_postal_code(postal_code, country) when is_binary(country) do
    if country = get_country(country) do
      do_parse_postal_code(postal_code, country)
    end
  end

  defp do_parse_postal_code(postal_code, %Country{postal_code_regex: regex}) do
    case regex do
      %Regex{} -> Regex.run(regex, postal_code, capture: :first)
      nil -> nil
    end
  end
end
