class DropDupeIndexes < ActiveRecord::Migration
  def up
    remove_index :agents,       :name => "id_UNIQUE"
    remove_index :host_groups,  :name => "id_UNIQUE"
    remove_index :orgs,         :name => "id_UNIQUE"
    remove_index :repos,        :name => "id_UNIQUE"
    remove_index :taggings,     :name => "id_UNIQUE"
  end
end
