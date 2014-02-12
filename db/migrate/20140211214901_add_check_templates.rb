class AddCheckTemplates < ActiveRecord::Migration
  def up

    create_table :check_templates do |t|
      t.integer :org_id, :null => true
      t.string :name, :limit => 255, :null => false
      t.integer :mode, :limit => 2, :null => false
      t.string :tags, :limit => 255, :null => true
    end
    add_foreign_key("check_templates", "orgs")

    create_table :check_template_items do |t|
      t.integer  :check_template_id, :null => false
      t.integer  :command_id, :null => false
      t.text     :args
    end
    add_foreign_key("check_template_items", "check_templates")
    add_foreign_key("check_template_items", "commands")

  end

  def down
    drop_table :check_template_items
    drop_table :check_templates
  end
end
