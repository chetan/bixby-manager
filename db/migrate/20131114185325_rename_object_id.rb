class RenameObjectId < ActiveRecord::Migration
  def up
    rename_column :metadata, :object_id, :object_fk_id
  end
end
