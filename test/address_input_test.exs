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

      assert is_list(countries)
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
      assert %AddressInput.Country{id: "US"} = AddressInput.get_country("data/us")
    end

    test "returns nil for unknown countries" do
      assert is_nil(AddressInput.get_country("ZZ"))
    end
  end
end
