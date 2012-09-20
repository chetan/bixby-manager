class AddTenantPrivateKey < ActiveRecord::Migration
  def up
    add_column "tenants", "private_key", :text,:default => nil
  end

  def down
    remove_column "tenants", "private_key"
  end
end
