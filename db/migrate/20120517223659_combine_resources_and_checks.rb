class CombineResourcesAndChecks < ActiveRecord::Migration
  def up

    drop_fk :checks, "fk_checks_resources1"
    drop_fk :metrics, "fk_metrics_resources"
    remove_column :checks, :resource_id
    remove_column :metrics, :resource_id

    # add host_id and set correct value
    change_table :checks do |t|
      t.add_id :host_id, :after => :id
    end
    Check.find(:all).each do |check|
      check.host_id = check.agent.host.id
      check.save!
    end
    add_fk :checks, :host

    drop_table :resources
  end

  def down
    raise ActiveRecord::IrreversibleMigration.new("can't reverse this")
  end
end
