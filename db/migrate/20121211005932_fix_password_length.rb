class FixPasswordLength < ActiveRecord::Migration
  def up
    change_table :tenants do |t|
      t.change :password, :string, :limit => 255
    end
    change_table :users do |t|
      t.change :password, :string, :limit => 255
    end
  end

  def down
  end
end
