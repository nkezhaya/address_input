defmodule AddressInput.Country do
  @moduledoc """
  Country metadata parsed from the libaddressinput dataset.

  ## Fields

  - `id` - ISO 3166-1 alpha-2 code.
  - `name` - localized display name from the dataset.
  - `default_language` - language code used for labels.
  - `required_fields` - list of required address components as atoms, derived
    from the dataset codes (`N`, `O`, `A`, `D`, `C`, `S`, `Z`, `X`).
  - `subregions` - list of [Subregion](`AddressInput.Subregion`) entries.
  - `sublocality_type` - label hint for the city-level field when present.
  - `subregion_type` - label hint for the region/state field when present.
  - `postal_code_type` - label hint for the postal code field when present.
  - `postal_code_regex` - compiled regex for validating postal codes.
  - `address_format` - parsed formatting template from the dataset (`fmt`).
  - `local_address_format` - parsed local formatting template (`lfmt`) when present.

  ## Format tokens

  The `address_format` fields store a tokenized representation of the raw
  template string. You can inspect the tokens to build rendering or validation
  helpers without re-parsing the source template.

  The token list preserves the order of the original template and contains one
  of:

  - `{:field, field}` - a required address component, where `field` is one of
    the `AddressInput.Country.field()` atoms.
  - `{:text, string}` - literal text from the template.
  - `:newline` - a line break marker (the `%n` code in the dataset).

  Unknown format codes raise at parse time to surface dataset issues early.
  """

  @enforce_keys [
    :id,
    :name,
    :default_language,
    :required_fields,
    :subregions,
    :sublocality_type,
    :subregion_type,
    :postal_code_type,
    :postal_code_regex,
    :address_format,
    :local_address_format
  ]
  defstruct @enforce_keys

  @type field ::
          :name
          | :organization
          | :address
          | :dependent_locality
          | :sublocality
          | :region
          | :postal_code
          | :sorting_code

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          default_language: String.t(),
          required_fields: [field()],
          subregions: [AddressInput.Subregion.t()],
          sublocality_type: String.t() | nil,
          subregion_type: String.t() | nil,
          postal_code_type: String.t() | nil,
          postal_code_regex: Regex.t() | nil,
          address_format: AddressInput.address_format() | nil,
          local_address_format: AddressInput.address_format() | nil
        }
end
