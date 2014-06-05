class AddOrgToAnnotation < ActiveRecord::Migration
  def up
    add_column "annotations", :org_id, :integer, :null => false, :after => :id
  end
end
