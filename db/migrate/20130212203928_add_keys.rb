class AddKeys < ActiveRecord::Migration
  def change
    add_foreign_key "checks", "hosts", :name => "checks_host_id_fk"
  end
end
