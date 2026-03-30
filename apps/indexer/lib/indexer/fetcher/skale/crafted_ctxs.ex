defmodule Indexer.Fetcher.Skale.CraftedCtxs do
  @moduledoc """
  Fetches crafted CTX transaction hashes for SKALE origin transactions
  using the bite_getCraftedCtxs RPC method.

  ## Timing Strategy

  When block N is indexed, this fetcher is called for transactions in block N-1.
  Since CTX transactions are spawned in block N by smart contracts in block N-1,
  waiting until block N is indexed ensures the crafted CTXs already exist in the
  node before querying. This avoids any premature calls.

  ## RPC Response Format

  `bite_getCraftedCtxs` returns a list of transaction hashes (without "0x" prefix)
  for successful origin transactions, or an error for non-origin transactions (expected).
  """

  require Logger

  import EthereumJSONRPC, only: [json_rpc: 2]

  alias Explorer.Chain.{Hash}
  alias Explorer.Chain.Skale.CraftedCtx
  alias Explorer.Repo
  alias Indexer.Fetcher.Skale.Utils.Rpc

  @rpc_batch_size 50

  @doc """
  Fetches crafted CTX hashes for the given origin transaction hashes and persists
  the associations to the database.

  ## Parameters
  - `transaction_hashes`: List of origin transaction hashes to query
  - `json_rpc_named_arguments`: RPC connection configuration

  ## Returns
  `:ok` on completion (errors are logged, not raised)

  ## Notes
  - Most transactions will return an error (not an origin of any CTX) — this is expected
  - Insertions are idempotent via `on_conflict: :nothing`
  - Processes transactions in batches of #{@rpc_batch_size}
  """
  @spec fetch_and_update([Hash.Full.t()], keyword()) :: :ok
  def fetch_and_update(transaction_hashes, json_rpc_named_arguments) when is_list(transaction_hashes) do
    if Enum.empty?(transaction_hashes) do
      :ok
    else
      transaction_hashes
      |> Enum.chunk_every(@rpc_batch_size)
      |> Enum.each(fn chunk ->
        chunk
        |> build_requests()
        |> json_rpc(json_rpc_named_arguments)
        |> process_responses(chunk)
      end)

      :ok
    end
  end

  # Build RPC requests for bite_getCraftedCtxs
  @spec build_requests([Hash.Full.t()]) :: [EthereumJSONRPC.Transport.request()]
  defp build_requests(transaction_hashes) do
    transaction_hashes
    |> Enum.with_index()
    |> Enum.map(fn {hash, index} ->
      Rpc.crafted_ctxs_request(hash, index)
    end)
  end

  # Process batch responses and insert associations into the database
  @spec process_responses({:ok, [map()]} | {:error, term()}, [Hash.Full.t()]) :: :ok
  defp process_responses({:ok, responses}, transaction_hashes) do
    now = DateTime.utc_now()

    rows =
      responses
      |> Enum.flat_map(fn response ->
        case response do
          %{id: id, result: crafted_hashes} when is_list(crafted_hashes) and length(crafted_hashes) > 0 ->
            origin_hash = Enum.at(transaction_hashes, id)
            build_rows(origin_hash, crafted_hashes, now)

          %{id: _id, error: %{message: message}} ->
            # Expected for transactions that are not CTX origins
            Logger.debug("No crafted CTXs for transaction: #{message}")
            []

          _other ->
            []
        end
      end)

    if length(rows) > 0 do
      Repo.insert_all(
        CraftedCtx,
        rows,
          conflict_target: [:origin_transaction_hash, :crafted_transaction_hash],
        on_conflict: :nothing
      )

      Logger.info("Inserted #{length(rows)} crafted CTX associations")
    else
      Logger.debug("No crafted CTXs found in batch (expected — most transactions are not CTX origins)")
    end

    :ok
  end

  defp process_responses({:error, reason}, _transaction_hashes) do
    Logger.error("Failed to fetch crafted CTXs: #{inspect(reason)}")
    :ok
  end

  # Build row maps for insert_all from a list of crafted CTX hash hex strings
  @spec build_rows(Hash.Full.t(), [binary()], DateTime.t()) :: [map()]
  defp build_rows(origin_hash, crafted_hashes, now) do
    crafted_hashes
    |> Enum.reduce([], fn crafted_hex, acc ->
      # SKALE RPC returns hashes without "0x" prefix
      crafted_hex_normalized =
        if String.starts_with?(crafted_hex, "0x"), do: crafted_hex, else: "0x" <> crafted_hex

      case Hash.Full.cast(crafted_hex_normalized) do
        {:ok, crafted_hash} ->
          [
            %{
              origin_transaction_hash: origin_hash,
              crafted_transaction_hash: crafted_hash,
              inserted_at: now,
              updated_at: now
            }
            | acc
          ]

        _error ->
          Logger.debug("Failed to cast crafted CTX hash: #{crafted_hex_normalized}")
          acc
      end
    end)
  end
end
