defmodule Indexer.Fetcher.Skale.CtxOrigin do
  @moduledoc """
  Fetches CTX origin transaction hashes for SKALE CTX transactions
  using the bite_getCtxOrigin RPC method.

  CTX (Conditional Transaction) are special transactions created by smart contracts
  in block N that execute in block N+1. This fetcher retrieves the origin transaction
  hash for each CTX transaction.

  ## Delayed Processing Strategy
  To handle the N+1 block dependency, this fetcher processes transactions from the
  previous block when a new block is indexed. This ensures CTX transactions exist
  before we query their origin.
  """

  require Logger

  import EthereumJSONRPC, only: [json_rpc: 2]
  import Ecto.Query, only: [from: 2]

  alias Explorer.Chain.{Hash, Transaction}
  alias Explorer.Repo
  alias Indexer.Fetcher.Skale.Utils.Rpc

  @rpc_batch_size 50

  @doc """
  Fetches CTX origins for transactions and updates the database.

  ## Parameters
  - `transaction_hashes`: List of transaction hashes to check for CTX origins
  - `json_rpc_named_arguments`: RPC connection configuration

  ## Returns
  `:ok` on successful completion

  ## Notes
  - Most transactions will return an error (not a CTX), which is expected
  - Only successful responses will update the database
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

  # Build RPC requests for bite_getCtxOrigin
  @spec build_requests([Hash.Full.t()]) :: [EthereumJSONRPC.Transport.request()]
  defp build_requests(transaction_hashes) do
    transaction_hashes
    |> Enum.with_index()
    |> Enum.map(fn {hash, index} ->
      Rpc.ctx_origin_request(hash, index)
    end)
  end

  # Process responses and update database
  @spec process_responses({:ok, [map()]} | {:error, term()}, [Hash.Full.t()]) :: :ok
  defp process_responses({:ok, responses}, transaction_hashes) do
    # Create a map of transaction hash to origin hash for successful responses
    ctx_origins =
      responses
      |> Enum.reduce(%{}, fn response, acc ->
        case response do
          %{id: id, result: origin_hash_hex} when is_binary(origin_hash_hex) ->
            transaction_hash = Enum.at(transaction_hashes, id)

            # SKALE RPC returns hash without "0x" prefix, add it for Hash.Full.cast
            origin_hash_with_prefix =
              if String.starts_with?(origin_hash_hex, "0x") do
                origin_hash_hex
              else
                "0x" <> origin_hash_hex
              end

            case Hash.Full.cast(origin_hash_with_prefix) do
              {:ok, origin_hash_struct} ->
                Map.put(acc, transaction_hash, origin_hash_struct)

              _error ->
                Logger.debug("Failed to cast origin hash: #{origin_hash_with_prefix}")
                acc
            end

          %{id: _id, error: %{message: message}} ->
            # Expected for non-CTX transactions
            Logger.debug("Transaction is not a CTX: #{message}")
            acc

          _other ->
            acc
        end
      end)

    # Update transactions with CTX origins
    if map_size(ctx_origins) > 0 do
      update_transactions(ctx_origins)
      Logger.info("Updated #{map_size(ctx_origins)} transactions with CTX origins")
    else
      Logger.debug("No CTX transactions found in this batch (expected - most transactions are not CTXs)")
    end

    :ok
  end

  defp process_responses({:error, reason}, _transaction_hashes) do
    Logger.error("Failed to fetch CTX origins: #{inspect(reason)}")
    :ok
  end

  # Update transactions in the database
  @spec update_transactions(%{Hash.Full.t() => Hash.Full.t()}) :: :ok
  defp update_transactions(ctx_origins) do
    Enum.each(ctx_origins, fn {transaction_hash, origin_hash} ->
      query =
        from(
          t in Transaction,
          where: t.hash == ^transaction_hash,
          update: [set: [ctx_origin_transaction_hash: ^origin_hash]]
        )

      Repo.update_all(query, [])
    end)

    :ok
  end
end
