class AddTimestampsForHosts < ActiveRecord::Migration
  def up
    change_table :hosts do |t|
      t.timestamps
    end
  end

  def down
    remove_column :hosts, :created_at
    remove_column :hosts, :updated_at
  end
end
