class AddPermissionTables < ActiveRecord::Migration
  def up

    create_table :roles do |t|
      t.integer :tenant_id, :null => true
      t.string :name, :limit => 255, :null => false
      t.string :description, :limit => 255, :null => true
    end
    add_foreign_key(:roles, :tenants)

    create_table :permissions do |t|
      t.string :name, :limit => 255, :null => false
      t.string :description, :limit => 255, :null => true
    end

    create_table :user_permissions do |t|
      t.integer :user_id, :null => false
      t.integer :permission_id, :null => false
      t.string :resource, :null => true
      t.integer :resource_id, :null => true
    end
    add_foreign_key(:user_permissions, :users)
    add_foreign_key(:user_permissions, :permissions)

    create_table :role_permissions do |t|
      t.integer :role_id, :null => false
      t.integer :permission_id, :null => false
      t.string :resource, :null => true
      t.integer :resource_id, :null => true
    end
    add_foreign_key(:role_permissions, :roles)
    add_foreign_key(:role_permissions, :permissions)

    create_table(:users_roles, :id => false) do |t|
      t.integer :user_id, :null => false
      t.integer :role_id, :null => false
    end
    add_foreign_key(:users_roles, :users)
    add_foreign_key(:users_roles, :roles)


    # create a first role & permission
    Role.reset_column_information
    Permission.reset_column_information

    god = Role.new(:name => "god")
    imp = Permission.new(:name => "impersonate_users")
    imp.save
    god.add_permission(imp)
    god.save

  end

  def down
    drop_table :users_roles
    drop_table :users_permissions
    drop_table :roles_permissions
    drop_table :roles
    drop_table :permissions
  rescue => ex
  end
end
