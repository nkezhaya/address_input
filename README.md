# AddressInput

Loads and queries address metadata derived from the
[libaddressinput](https://github.com/google/libaddressinput) dataset.

It provides a small, stable API for reading country and subregion metadata that
you can use to build address forms or validation rules.

## Features

- Parse the libaddressinput dataset into typed structs.
- Query a sorted list of countries with subregion data.
- Keep the dataset in `priv/metadata.json` to avoid runtime network calls.

## Quickstart

`AddressInput.countries/0` returns a list of `AddressInput.Country` structs
sorted by country id. Use `AddressInput.get_country/1` to fetch a single
country by code.

```elixir
%AddressInput.Country{
  id: "US",
  name: "UNITED STATES",
  default_language: "en",
  required_fields: [:address, :sublocality, :region, :postal_code],
  sublocality_type: "city",
  subregion_type: "state",
  postal_code_type: "zip",
  subregions: [
    %AddressInput.Subregion{id: "AK", iso_code: "AK", name: "Alaska"},
    ...
  ]
}
```

## Attribution

This package includes metadata derived from libaddressinput:
https://github.com/google/libaddressinput

The metadata is licensed under CC-BY 4.0:
https://creativecommons.org/licenses/by/4.0/

Changes: extracted JSON and normalized fields; see `priv/metadata.json`.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `address_input` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:address_input, "~> 0.1"}
  ]
end
```

## License

Code is licensed under MIT. Metadata is licensed by Google under CC-BY 4.0.
