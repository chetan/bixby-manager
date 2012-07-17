class AddTenantPrivateKey < ActiveRecord::Migration
  def up
    add_column "tenants", "public_key", :text,:default => nil
  end

  def down
    drop_column "tenants", "public_key"
  end
end
