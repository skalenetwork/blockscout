defmodule Explorer.Chain.Skale.CraftedCtx do
  @moduledoc """
  Schema for SKALE crafted CTX associations.

  Stores the relationship between an origin transaction and the CTX transactions
  it caused to be crafted and executed in the next block.

  One origin transaction may produce multiple crafted CTXs.
  """

  use Explorer.Schema

  import Ecto.Query, only: [from: 2]

  alias Explorer.Chain.Hash
  alias Explorer.Repo

  @required_attrs ~w(origin_transaction_hash crafted_transaction_hash)a

  @primary_key false
  typed_schema "skale_crafted_ctxs" do
    field(:origin_transaction_hash, Hash.Full, primary_key: true)
    field(:crafted_transaction_hash, Hash.Full, primary_key: true)

    timestamps()
  end

  def changeset(%__MODULE__{} = struct, attrs) do
    struct
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
  end

  @doc """
  Returns all crafted CTX hashes for the given origin transaction hash.
  """
  @spec for_origin(Hash.Full.t()) :: [Hash.Full.t()]
  def for_origin(origin_hash) do
    query =
      from(c in __MODULE__,
        where: c.origin_transaction_hash == ^origin_hash,
        select: c.crafted_transaction_hash,
        order_by: c.crafted_transaction_hash
      )

    Repo.all(query)
  end

  @doc """
  Returns true if any crafted CTX records exist for the given origin transaction hash.
  """
  @spec exists_for_origin?(Hash.Full.t()) :: boolean
  def exists_for_origin?(origin_hash) do
    query =
      from(c in __MODULE__,
        where: c.origin_transaction_hash == ^origin_hash,
        limit: 1,
        select: true
      )

    Repo.exists?(query)
  end
end
