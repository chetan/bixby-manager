class CreateAnnotations < ActiveRecord::Migration
  def up
    create_table :annotations, { :id => false } do |t|
      t.add_id :id
      t.string :name
      t.string :detail
      t.timestamp :created_at
    end
    create_table :hosts_annotations, { :id => false } do |t|
      t.add_id :host_id
      t.add_id :annotation_id
    end
    add_fk :hosts_annotations, :host
    add_fk :hosts_annotations, :annotation
  end

  def down
    drop_table :annotations
    drop_table :hosts_annotations
  end
end
