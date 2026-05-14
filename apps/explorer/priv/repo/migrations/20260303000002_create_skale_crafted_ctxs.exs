defmodule Explorer.Repo.Migrations.CreateSkaleCraftedCtxs do
  use Ecto.Migration

  def change do
    create table(:skale_crafted_ctxs, primary_key: false) do
      add(:origin_transaction_hash, :bytea, null: false, primary_key: true)
      add(:crafted_transaction_hash, :bytea, null: false, primary_key: true)

      timestamps(null: false)
    end

    # Index for fast lookups of crafted CTXs by origin transaction
    create(index(:skale_crafted_ctxs, [:origin_transaction_hash]))
  end
end
