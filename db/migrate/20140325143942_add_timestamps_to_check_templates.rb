class AddTimestampsToCheckTemplates < ActiveRecord::Migration
  def up
    add_column "check_templates", :created_at, :timestamp
    add_column "check_templates", :updated_at, :timestamp
    add_column "check_templates", :deleted_at, :timestamp
    add_column "check_template_items", :created_at, :timestamp
    add_column "check_template_items", :updated_at, :timestamp
    add_column "check_template_items", :deleted_at, :timestamp

    CheckTemplate.reset_column_information
    CheckTemplateItem.reset_column_information

    CheckTemplate.all.each do |c|
      c.created_at = Time.new
      c.updated_at = Time.new
      c.save
    end

    CheckTemplateItem.all.each do |c|
      c.created_at = Time.new
      c.updated_at = Time.new
      c.save
    end
  end

  def down
    remove_column "check_templates", :created_at
    remove_column "check_templates", :updated_at
    remove_column "check_templates", :deleted_at
    remove_column "check_template_items", :created_at
    remove_column "check_template_items", :updated_at
    remove_column "check_template_items", :deleted_at
  end
end
