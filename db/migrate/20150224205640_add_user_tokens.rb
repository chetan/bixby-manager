class AddUserTokens < ActiveRecord::Migration
  def change

    create_table :tokens do |t|
      t.integer :org_id
      t.integer :user_id
      t.string  :token, :limit => 16
      t.string  :purpose, :limit => 255

      t.timestamp :created_at
      t.timestamp :last_used_at
      t.timestamp :deleted_at
    end

    add_foreign_key :tokens, :orgs
    add_foreign_key :tokens, :users

    Token.reset_column_information
    User.all.each do |u|
      Token.create(u, "default")
    end

  end
end
