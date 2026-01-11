defmodule Mix.Tasks.AddressInput.UpdateMetadata do
  @shortdoc "Update metadata"
  @moduledoc "Update metadata from the libaddressinput data source."

  use Mix.Task

  @impl Mix.Task
  def run(_) do
    {:ok, _} = Application.ensure_all_started(:req)

    base_url = "https://chromium-i18n.appspot.com"
    index_url = base_url <> "/ssl-address"

    paths = fetch_paths(index_url)

    metadata =
      paths
      |> Task.async_stream(
        fn path -> fetch_metadata(base_url, path) end,
        max_concurrency: 4,
        ordered: false,
        timeout: :infinity
      )
      |> Enum.reduce(%{}, fn
        {:ok, {key, value}}, acc ->
          Map.put(acc, key, value)

        {:exit, reason}, _acc ->
          raise "metadata download failed: #{inspect(reason)}"
      end)

    File.write!("priv/metadata.json", JSON.encode!(metadata))
  end

  defp fetch_paths(index_url) do
    response = Req.get!(index_url)

    response.body
    |> extract_paths()
    |> Enum.uniq()
  end

  defp extract_paths(body) do
    doc = LazyHTML.from_document(body)
    links = LazyHTML.attribute(doc["a[href]"], "href")

    Enum.filter(links, &String.starts_with?(&1, "/ssl-address/data"))
  end

  defp fetch_metadata(base_url, path) do
    response = Req.get!(base_url <> URI.encode(path))

    key = String.replace_prefix(path, "/ssl-address/", "")
    value = JSON.decode!(response.body)

    {key, value}
  end
end
