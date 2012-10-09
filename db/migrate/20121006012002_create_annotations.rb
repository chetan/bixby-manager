class CreateAnnotations < ActiveRecord::Migration
  def up
    create_table :annotations, { :id => false } do |t|
      t.add_id :id
      t.add_id :host_id, :null => true
      t.string :name
      t.string :detail
      t.timestamp :created_at
    end
    add_fk :annotations, :host
  end

  def down
    drop_table :annotations
  end
end
