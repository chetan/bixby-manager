class AddHostGroups < ActiveRecord::Migration
  def up
    create_table :host_groups, { :id => false } do |t|
      t.add_id
      t.add_id :org_id
      t.add_id :parent_id
      t.string :name
    end

    add_fk :host_groups, :parent_id

    create_table :hosts_host_groups, { :id => false } do |t|
      t.add_id :host_id
      t.add_id :host_group_id
    end

    add_fk :hosts_host_groups, :host
    add_fk :hosts_host_groups, :host_group
  end

  def down
    drop_table :hosts_host_groups
    drop_table :host_groups
  end
end
