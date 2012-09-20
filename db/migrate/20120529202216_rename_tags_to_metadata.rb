class RenameTagsToMetadata < ActiveRecord::Migration
  def up
    disable_referential_integrity do
      rename_table :tags, :metadata
      drop_fk :metrics_tags, "fk_metrics_tags_tags"
      rename_table :metrics_tags, :metrics_metadata
      rename_column :metrics_metadata, :tag_id, :metadata_id
      add_fk :metrics_metadata, :metadata
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration.new("can't reverse this")
  end
end
