class AddedTypeToMetadata < ActiveRecord::Migration
  def up
    change_table :metadata do |t|
      t.integer "source", :limit => 2, :default => 1
    end
    execute "UPDATE metadata SET source=1" # default value = 1 (custom)
  end

  def down
    remove_column :metadata, :source
  end
end
