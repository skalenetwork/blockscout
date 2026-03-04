defmodule Explorer.Repo.Migrations.AddCtxOriginToTransactions do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add(:ctx_origin_transaction_hash, :bytea, null: true)
    end

    create(index(:transactions, [:ctx_origin_transaction_hash]))
  end
end
