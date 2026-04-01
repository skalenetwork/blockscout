defmodule Indexer.Fetcher.Skale.Utils.Rpc do
  @moduledoc """
  RPC utilities for SKALE-specific methods like bite_getCtxOrigin.
  """

  import EthereumJSONRPC, only: [request: 1]

  alias Explorer.Chain.Hash

  @doc """
  Creates a bite_getCtxOrigin RPC request.

  ## Parameters
  - `transaction_hash`: The transaction hash to query (binary or Hash.Full.t())
  - `id`: The JSON-RPC request ID

  ## Returns
  A JSON-RPC request map for the bite_getCtxOrigin method.

  ## Example
      iex> ctx_origin_request("0xc49b7e8c461eeec730fe28a0978dfd09f4a8b3a9a1a67f3a39186950e153b2c2", 1)
      %{
        id: 1,
        jsonrpc: "2.0",
        method: "bite_getCtxOrigin",
        params: ["0xc49b7e8c461eeec730fe28a0978dfd09f4a8b3a9a1a67f3a39186950e153b2c2"]
      }
  """
  @spec ctx_origin_request(binary() | Hash.Full.t(), non_neg_integer()) ::
          EthereumJSONRPC.Transport.request()
  def ctx_origin_request(transaction_hash, id) when is_binary(transaction_hash) do
    request(%{
      id: id,
      method: "bite_getCtxOrigin",
      params: [transaction_hash]
    })
  end

  def ctx_origin_request(%Hash{byte_count: 32} = transaction_hash, id) do
    ctx_origin_request(Hash.to_string(transaction_hash), id)
  end

  @doc """
  Creates a bite_getCraftedCtxs RPC request.

  ## Parameters
  - `transaction_hash`: The origin transaction hash to query (binary or Hash.Full.t())
  - `id`: The JSON-RPC request ID

  ## Returns
  A JSON-RPC request map for the bite_getCraftedCtxs method.

  ## Example
      iex> crafted_ctxs_request("0x4dbbbe90dc0d470da288964ca7d59a163698a1b6d4eb62c0c9b35087e31e7d33", 1)
      %{
        id: 1,
        jsonrpc: "2.0",
        method: "bite_getCraftedCtxs",
        params: ["0x4dbbbe90dc0d470da288964ca7d59a163698a1b6d4eb62c0c9b35087e31e7d33"]
      }
  """
  @spec crafted_ctxs_request(binary() | Hash.Full.t(), non_neg_integer()) ::
          EthereumJSONRPC.Transport.request()
  def crafted_ctxs_request(transaction_hash, id) when is_binary(transaction_hash) do
    request(%{
      id: id,
      method: "bite_getCraftedCtxs",
      params: [transaction_hash]
    })
  end

  def crafted_ctxs_request(%Hash{byte_count: 32} = transaction_hash, id) do
    crafted_ctxs_request(Hash.to_string(transaction_hash), id)
  end
end
