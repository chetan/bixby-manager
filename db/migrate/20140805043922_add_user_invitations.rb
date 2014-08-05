class AddUserInvitations < ActiveRecord::Migration
  def change
    add_column :users, :invite_token, :string
    add_column :users, :invite_created_at, :datetime
    add_column :users, :invite_sent_at, :datetime
    add_column :users, :invite_accepted_at, :datetime
    add_column :users, :invited_by_id, :integer
  end
end
