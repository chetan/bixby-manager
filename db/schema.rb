# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121006012002) do

  create_table "agents", :force => true do |t|
    t.integer  "host_id",                                     :null => false
    t.string   "uuid"
    t.string   "ip",         :limit => 16
    t.integer  "port",       :limit => 2,  :default => 18000
    t.text     "public_key"
    t.integer  "status",     :limit => 2,  :default => 0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "agents", ["host_id"], :name => "fk_agents_hosts1"
  add_index "agents", ["id"], :name => "id_UNIQUE", :unique => true

  create_table "annotations", :force => true do |t|
    t.integer  "host_id",    :null => false
    t.string   "name"
    t.string   "detail"
    t.datetime "created_at"
  end

  add_index "annotations", ["host_id"], :name => "index_annotations_on_host_id"

  create_table "checks", :force => true do |t|
    t.integer "host_id",                                         :null => false
    t.integer "agent_id",                                        :null => false
    t.integer "command_id",                                      :null => false
    t.text    "args"
    t.integer "normal_interval", :limit => 2
    t.integer "retry_interval",  :limit => 2
    t.integer "timeout",         :limit => 2
    t.boolean "plot"
    t.boolean "enabled",                      :default => false
  end

  add_index "checks", ["agent_id"], :name => "fk_checks_agents1"
  add_index "checks", ["command_id"], :name => "fk_checks_commands1"

  create_table "commands", :force => true do |t|
    t.integer  "repo_id"
    t.string   "name"
    t.string   "bundle"
    t.string   "command"
    t.text     "options"
    t.datetime "updated_at"
  end

  add_index "commands", ["repo_id"], :name => "fk_commands_repos1"

  create_table "host_groups", :force => true do |t|
    t.integer "org_id",    :null => false
    t.integer "parent_id"
    t.string  "name",      :null => false
  end

  add_index "host_groups", ["id"], :name => "id_UNIQUE", :unique => true
  add_index "host_groups", ["org_id"], :name => "fk_host_groups_orgs1"
  add_index "host_groups", ["parent_id"], :name => "fk_host_groups_host_groups1"

  create_table "hosts", :force => true do |t|
    t.integer  "org_id",                   :null => false
    t.string   "ip",         :limit => 16
    t.string   "hostname"
    t.string   "alias"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "hosts", ["org_id"], :name => "fk_hosts_orgs1"

  create_table "hosts_host_groups", :id => false, :force => true do |t|
    t.integer "host_id",       :null => false
    t.integer "host_group_id", :null => false
  end

  add_index "hosts_host_groups", ["host_group_id"], :name => "fk_hosts_host_groups_host_groups1"
  add_index "hosts_host_groups", ["host_id"], :name => "fk_hosts_host_groups_hosts1"

  create_table "hosts_metadata", :id => false, :force => true do |t|
    t.integer "host_id",     :null => false
    t.integer "metadata_id", :null => false
  end

  add_index "hosts_metadata", ["host_id"], :name => "fk_hosts_metadata_hosts1"
  add_index "hosts_metadata", ["metadata_id"], :name => "fk_hosts_metadata_metadata1"

  create_table "metadata", :force => true do |t|
    t.string  "key",                                :null => false
    t.text    "value",                              :null => false
    t.integer "source", :limit => 2, :default => 1, :null => false
  end

  create_table "metric_infos", :force => true do |t|
    t.integer "command_id", :null => false
    t.string  "metric",     :null => false
    t.string  "unit"
    t.string  "desc"
    t.string  "label"
  end

  add_index "metric_infos", ["command_id"], :name => "fk_command_keys_commands1"

  create_table "metrics", :force => true do |t|
    t.integer  "check_id",                                                :null => false
    t.string   "name"
    t.string   "key",                                                     :null => false
    t.string   "tag_hash",   :limit => 32,                                :null => false
    t.integer  "status",     :limit => 2
    t.decimal  "last_value",               :precision => 20, :scale => 2
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at"
  end

  add_index "metrics", ["check_id"], :name => "fk_metrics_checks1"

  create_table "metrics_metadata", :id => false, :force => true do |t|
    t.integer "metric_id",   :null => false
    t.integer "metadata_id", :null => false
  end

  add_index "metrics_metadata", ["metadata_id"], :name => "fk_metrics_metadata_metadata1"
  add_index "metrics_metadata", ["metric_id"], :name => "fk_metrics_metadata_metrics1"

  create_table "orgs", :force => true do |t|
    t.integer "tenant_id"
    t.string  "name"
  end

  add_index "orgs", ["id"], :name => "id_UNIQUE", :unique => true
  add_index "orgs", ["tenant_id"], :name => "fk_orgs_tenants1"

  create_table "repos", :force => true do |t|
    t.integer  "org_id"
    t.string   "name"
    t.string   "uri"
    t.string   "branch"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "repos", ["id"], :name => "id_UNIQUE", :unique => true
  add_index "repos", ["org_id"], :name => "fk_repos_orgs1"

  create_table "resources", :force => true do |t|
    t.integer "host_id", :null => false
    t.string  "name"
  end

  add_index "resources", ["host_id"], :name => "fk_resources_hosts1"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id",                       :null => false
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["id"], :name => "id_UNIQUE", :unique => true
  add_index "taggings", ["tag_id"], :name => "fk_taggings_tags1"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "tenants", :force => true do |t|
    t.string "name"
    t.string "password",    :limit => 32
    t.text   "private_key"
  end

  create_table "users", :force => true do |t|
    t.integer "org_id",   :null => false
    t.string  "username", :null => false
    t.string  "password"
    t.string  "name"
    t.string  "email"
    t.string  "phone"
  end

  add_index "users", ["org_id"], :name => "fk_users_orgs1"

end
