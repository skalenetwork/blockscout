defmodule Indexer.Fetcher.Skale.CraftedCtxs do
  @moduledoc """
  Fetches derived CTX transaction hashes for SKALE origin transactions
  using the bite_getCraftedCtxs RPC method.

  ## Timing Strategy

  When block N is indexed, this fetcher is called for transactions in block N-1.
  Since CTX transactions are spawned in block N by smart contracts in block N-1,
  waiting until block N is indexed ensures the derived CTXs already exist in the
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

 
end
