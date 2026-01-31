defmodule AddressInputTest do
  use ExUnit.Case

  describe "countries/0" do
    test "returns countries sorted by name" do
      names =
        AddressInput.countries()
        |> Enum.map(& &1.name)

      assert names == Enum.sort(names)
    end

    test "parses country and subregion data" do
      countries = AddressInput.countries()

      assert [%AddressInput.Country{} | _] = countries

      us = Enum.find(countries, &(&1.id == "US"))

      assert us.name == "UNITED STATES"
      assert us.default_language == "en"
      assert :postal_code in us.required_fields
      assert Enum.any?(us.subregions, &(&1.id == "AK" and &1.name == "Alaska"))
    end
  end

  describe "get_country/1" do
    test "returns a country when it exists" do
      assert %AddressInput.Country{id: "US"} = AddressInput.get_country("US")
    end

    test "normalizes the country code" do
      assert %AddressInput.Country{id: "US"} = AddressInput.get_country("us")
    end

    test "returns nil for unknown countries" do
      refute AddressInput.get_country("ZZ")
    end

    test "stores parsed tokens on the country struct" do
      country = AddressInput.get_country("US")

      assert country.address_format == [
               {:field, :name},
               :newline,
               {:field, :organization},
               :newline,
               {:field, :address},
               :newline,
               {:field, :sublocality},
               {:text, ", "},
               {:field, :region},
               {:text, " "},
               {:field, :postal_code}
             ]
    end
  end

  describe "parse_postal_code/2" do
    test "returns the matching postal code for known formats" do
      assert {:ok, "95000"} = AddressInput.parse_postal_code("95000", "US")
      assert {:ok, "95000-1234"} = AddressInput.parse_postal_code("95000-1234", "US")

      assert {:ok, "95000"} =
               AddressInput.parse_postal_code("95000", AddressInput.get_country("US"))
    end

    test "rejects non-matching values" do
      assert :error = AddressInput.parse_postal_code("9500", "US")
      assert :error = AddressInput.parse_postal_code("95000-1234 extra", "US")
    end

    test "returns :error when the country has no postal code regex" do
      assert %AddressInput.Country{} = AddressInput.get_country("UG")
      assert :error = AddressInput.parse_postal_code("12345", "UG")
    end
  end
end
