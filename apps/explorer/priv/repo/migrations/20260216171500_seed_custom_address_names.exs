defmodule Explorer.Repo.Migrations.SeedCustomAddressNames do
  use Ecto.Migration

  def up do
    execute("""
    INSERT INTO address_names (address_hash, name, "primary", inserted_at, updated_at)
    VALUES ('\\x42495445204D452049274d20454e435259505444', 'BITE', true, NOW(), NOW())
    ON CONFLICT DO NOTHING;
    """)
  end

  def down do
    execute("""
    DELETE FROM address_names
    WHERE address_hash = '\\x42495445204D452049274d20454e435259505444'
      AND name = 'BITE';
    """)
  end
end
