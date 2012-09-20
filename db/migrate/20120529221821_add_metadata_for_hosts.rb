class AddMetadataForHosts < ActiveRecord::Migration
  def up
    create_table :hosts_metadata, { :id => false } do |t|
      t.add_id :host_id
      t.add_id :metadata_id
    end

    add_fk :hosts_metadata, :host
    add_fk :hosts_metadata, :metadata
  end

  def down
    drop_table :hosts_metadata
  end
end
