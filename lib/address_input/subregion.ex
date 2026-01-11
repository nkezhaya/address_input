defmodule AddressInput.Subregion do
  @moduledoc """
  Subregion metadata parsed from the libaddressinput dataset.
  """

  @enforce_keys [:id, :iso_code, :name]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
          id: String.t(),
          iso_code: String.t() | nil,
          name: String.t()
        }
end
