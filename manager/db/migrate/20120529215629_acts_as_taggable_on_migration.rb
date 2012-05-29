class ActsAsTaggableOnMigration < ActiveRecord::Migration
  def self.up
    create_table :tags, { :id => false } do |t|
      t.add_id
      t.string :name
    end

    create_table :taggings, { :id => false } do |t|
      t.add_id
      t.add_id :tag_id

      # You should make sure that the column created is
      # long enough to store the required class names.
      t.add_id :taggable, :polymorphic => true
      t.add_id :tagger, :polymorphic => true

      # limit is created to prevent mysql error o index lenght for myisam table type.
      # http://bit.ly/vgW2Ql
      t.string :context, :limit => 128

      t.datetime :created_at
    end

    add_fk :taggings, :tag
    add_index :taggings, [:taggable_id, :taggable_type, :context]
  end

  def self.down
    drop_table :taggings
    drop_table :tags
  end
end
