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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140812133656) do

  create_table "actions", force: true do |t|
    t.integer  "trigger_id",            null: false
    t.integer  "action_type", limit: 2, null: false
    t.integer  "target_id",             null: false
    t.text     "args"
    t.datetime "deleted_at"
  end

  add_index "actions", ["trigger_id"], name: "actions_trigger_id_fk", using: :btree

  create_table "agents", force: true do |t|
    t.integer  "host_id",                                  null: false
    t.string   "uuid"
    t.string   "ip",           limit: 16
    t.integer  "port",         limit: 2,   default: 18000
    t.text     "public_key"
    t.string   "access_key",   limit: 32,                  null: false
    t.string   "secret_key",   limit: 128,                 null: false
    t.integer  "status",       limit: 2,   default: 0,     null: false
    t.string   "version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.datetime "last_seen_at"
    t.boolean  "is_connected",             default: false
  end

  add_index "agents", ["host_id"], name: "fk_agents_hosts1", using: :btree

  create_table "annotations", force: true do |t|
    t.integer  "org_id",     null: false
    t.integer  "host_id"
    t.string   "name",       null: false
    t.text     "detail"
    t.datetime "created_at"
  end

  add_index "annotations", ["host_id"], name: "fk_annotations_hosts1_idx", using: :btree

  create_table "bundles", force: true do |t|
    t.integer  "repo_id"
    t.string   "path"
    t.string   "name"
    t.text     "desc"
    t.string   "version"
    t.string   "digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "bundles", ["repo_id"], name: "bundles_repo_id_fk", using: :btree

  create_table "check_template_items", force: true do |t|
    t.integer  "check_template_id", null: false
    t.integer  "command_id",        null: false
    t.text     "args"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "check_template_items", ["check_template_id"], name: "check_template_items_check_template_id_fk", using: :btree
  add_index "check_template_items", ["command_id"], name: "check_template_items_command_id_fk", using: :btree

  create_table "check_templates", force: true do |t|
    t.integer  "org_id"
    t.string   "name",                 null: false
    t.integer  "mode",       limit: 2, null: false
    t.string   "tags"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "check_templates", ["org_id"], name: "check_templates_org_id_fk", using: :btree

  create_table "checks", force: true do |t|
    t.integer  "host_id",                                   null: false
    t.integer  "agent_id",                                  null: false
    t.integer  "command_id",                                null: false
    t.text     "args"
    t.integer  "normal_interval", limit: 2
    t.integer  "retry_interval",  limit: 2
    t.integer  "timeout",         limit: 2
    t.boolean  "plot"
    t.boolean  "enabled",                   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "checks", ["agent_id"], name: "fk_checks_agents1", using: :btree
  add_index "checks", ["command_id"], name: "fk_checks_commands1", using: :btree
  add_index "checks", ["host_id"], name: "checks_host_id_fk", using: :btree

  create_table "command_logs", force: true do |t|
    t.integer  "org_id"
    t.integer  "agent_id"
    t.integer  "command_id"
    t.text     "stdin"
    t.text     "args"
    t.boolean  "exec_status"
    t.integer  "exec_code"
    t.integer  "status"
    t.text     "stdout"
    t.text     "stderr"
    t.datetime "requested_at"
    t.decimal  "time_taken",   precision: 10, scale: 3
  end

  add_index "command_logs", ["agent_id"], name: "command_logs_agent_id_fk", using: :btree
  add_index "command_logs", ["command_id"], name: "command_logs_command_id_fk", using: :btree
  add_index "command_logs", ["org_id"], name: "command_logs_org_id_fk", using: :btree

  create_table "commands", force: true do |t|
    t.integer  "repo_id"
    t.integer  "bundle_id",  null: false
    t.string   "name"
    t.string   "desc"
    t.string   "location"
    t.string   "command"
    t.text     "options"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "commands", ["bundle_id"], name: "commands_bundle_id_fk", using: :btree
  add_index "commands", ["repo_id"], name: "fk_commands_repos1", using: :btree

  create_table "escalation_policies", force: true do |t|
    t.integer  "org_id",     null: false
    t.string   "name"
    t.integer  "on_call_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "escalation_policies", ["on_call_id"], name: "index_escalation_policies_on_on_call_id", using: :btree
  add_index "escalation_policies", ["org_id"], name: "index_escalation_policies_on_org_id", using: :btree

  create_table "host_groups", force: true do |t|
    t.integer "org_id",    null: false
    t.integer "parent_id"
    t.string  "name",      null: false
  end

  add_index "host_groups", ["org_id"], name: "fk_host_groups_orgs1", using: :btree
  add_index "host_groups", ["parent_id"], name: "fk_host_groups_host_groups1", using: :btree

  create_table "hosts", force: true do |t|
    t.integer  "org_id",                null: false
    t.string   "ip",         limit: 16
    t.string   "hostname"
    t.string   "alias"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "hosts", ["org_id"], name: "fk_hosts_orgs1", using: :btree

  create_table "hosts_host_groups", id: false, force: true do |t|
    t.integer "host_id",       null: false
    t.integer "host_group_id", null: false
  end

  add_index "hosts_host_groups", ["host_group_id"], name: "fk_hosts_host_groups_host_groups1", using: :btree
  add_index "hosts_host_groups", ["host_id"], name: "fk_hosts_host_groups_hosts1", using: :btree

  create_table "metadata", force: true do |t|
    t.integer "object_type",  limit: 2
    t.integer "object_fk_id"
    t.string  "key",                                null: false
    t.text    "value",                              null: false
    t.integer "source",       limit: 2, default: 1, null: false
  end

  create_table "metric_infos", force: true do |t|
    t.integer "command_id", null: false
    t.string  "metric",     null: false
    t.string  "unit"
    t.string  "desc"
    t.string  "label"
    t.string  "name"
    t.string  "range"
    t.string  "platforms"
  end

  add_index "metric_infos", ["command_id"], name: "fk_command_keys_commands1", using: :btree

  create_table "metrics", force: true do |t|
    t.integer  "check_id",                                        null: false
    t.string   "name"
    t.string   "key",                                             null: false
    t.string   "range"
    t.string   "tag_hash",    limit: 32,                          null: false
    t.integer  "status",      limit: 2
    t.decimal  "last_value",             precision: 20, scale: 2
    t.integer  "last_status", limit: 2
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at"
  end

  add_index "metrics", ["check_id", "key", "tag_hash"], name: "index_metrics_on_check_id_and_key_and_tag_hash", unique: true, using: :btree
  add_index "metrics", ["check_id"], name: "fk_metrics_checks1", using: :btree

  create_table "on_calls", force: true do |t|
    t.integer  "org_id",                    null: false
    t.string   "name"
    t.integer  "rotation_period", limit: 2
    t.integer  "handoff_day",     limit: 1
    t.time     "handoff_time"
    t.integer  "current_user_id"
    t.string   "users"
    t.datetime "next_handoff"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "on_calls", ["current_user_id"], name: "index_on_calls_on_current_user_id", using: :btree
  add_index "on_calls", ["org_id"], name: "index_on_calls_on_org_id", using: :btree

  create_table "orgs", force: true do |t|
    t.integer "tenant_id"
    t.string  "name"
  end

  add_index "orgs", ["tenant_id"], name: "fk_orgs_tenants1", using: :btree

  create_table "permissions", force: true do |t|
    t.string "name",        null: false
    t.string "description"
  end

  create_table "repos", force: true do |t|
    t.integer  "org_id"
    t.string   "name"
    t.string   "uri"
    t.string   "branch"
    t.text     "private_key"
    t.text     "public_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "repos", ["org_id"], name: "fk_repos_orgs1", using: :btree

  create_table "resources", force: true do |t|
    t.integer "host_id", null: false
    t.string  "name"
  end

  add_index "resources", ["host_id"], name: "fk_resources_hosts1", using: :btree

  create_table "role_permissions", force: true do |t|
    t.integer "role_id",       null: false
    t.integer "permission_id", null: false
    t.string  "resource"
    t.integer "resource_id"
  end

  add_index "role_permissions", ["permission_id"], name: "role_permissions_permission_id_fk", using: :btree
  add_index "role_permissions", ["role_id"], name: "role_permissions_role_id_fk", using: :btree

  create_table "roles", force: true do |t|
    t.integer "tenant_id"
    t.string  "name",        null: false
    t.string  "description"
  end

  add_index "roles", ["tenant_id"], name: "roles_tenant_id_fk", using: :btree

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id",                    null: false
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["tag_id"], name: "fk_taggings_tags1", using: :btree

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "tenants", force: true do |t|
    t.string "name"
    t.string "password"
    t.text   "private_key"
  end

  create_table "trigger_histories", force: true do |t|
    t.integer  "trigger_id",                                    null: false
    t.datetime "created_at"
    t.integer  "check_id"
    t.integer  "metric_id"
    t.integer  "severity",   limit: 2
    t.decimal  "threshold",            precision: 20, scale: 2
    t.string   "status"
    t.string   "sign",       limit: 2
    t.decimal  "value",                precision: 20, scale: 2
  end

  add_index "trigger_histories", ["check_id"], name: "trigger_histories_check_id_fk", using: :btree
  add_index "trigger_histories", ["metric_id"], name: "trigger_histories_metric_id_fk", using: :btree
  add_index "trigger_histories", ["trigger_id"], name: "trigger_histories_trigger_id_fk", using: :btree

  create_table "triggers", force: true do |t|
    t.integer  "check_id"
    t.integer  "metric_id"
    t.integer  "severity",   limit: 2
    t.decimal  "threshold",            precision: 20, scale: 2
    t.string   "status"
    t.string   "sign",       limit: 2
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.datetime "deleted_at"
  end

  add_index "triggers", ["check_id"], name: "triggers_check_id_fk", using: :btree
  add_index "triggers", ["metric_id"], name: "triggers_metric_id_fk", using: :btree

  create_table "user_permissions", force: true do |t|
    t.integer "user_id",       null: false
    t.integer "permission_id", null: false
    t.string  "resource"
    t.integer "resource_id"
  end

  add_index "user_permissions", ["permission_id"], name: "user_permissions_permission_id_fk", using: :btree
  add_index "user_permissions", ["user_id"], name: "user_permissions_user_id_fk", using: :btree

  create_table "users", force: true do |t|
    t.integer  "org_id",                                null: false
    t.string   "username",                              null: false
    t.string   "encrypted_password"
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.integer  "sign_in_count",             default: 0, null: false
    t.integer  "failed_attempts",           default: 0, null: false
    t.datetime "last_request_at"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_otp_secret"
    t.string   "encrypted_otp_secret_iv"
    t.string   "encrypted_otp_secret_salt"
    t.boolean  "otp_required_for_login"
    t.string   "otp_tmp_id"
    t.string   "invite_token"
    t.datetime "invite_created_at"
    t.datetime "invite_sent_at"
    t.datetime "invite_accepted_at"
    t.integer  "invited_by_id"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["last_request_at"], name: "index_users_on_last_request_at", using: :btree
  add_index "users", ["org_id"], name: "fk_users_orgs1", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: true do |t|
    t.integer "user_id", null: false
    t.integer "role_id", null: false
  end

  add_index "users_roles", ["role_id"], name: "users_roles_role_id_fk", using: :btree
  add_index "users_roles", ["user_id"], name: "users_roles_user_id_fk", using: :btree

  add_foreign_key "actions", "triggers", name: "actions_trigger_id_fk"

  add_foreign_key "agents", "hosts", name: "fk_agents_hosts1"

  add_foreign_key "annotations", "hosts", name: "fk_annotations_hosts1"

  add_foreign_key "bundles", "repos", name: "bundles_repo_id_fk"

  add_foreign_key "check_template_items", "check_templates", name: "check_template_items_check_template_id_fk"
  add_foreign_key "check_template_items", "commands", name: "check_template_items_command_id_fk"

  add_foreign_key "check_templates", "orgs", name: "check_templates_org_id_fk"

  add_foreign_key "checks", "agents", name: "fk_checks_agents1"
  add_foreign_key "checks", "commands", name: "fk_checks_commands1"
  add_foreign_key "checks", "hosts", name: "checks_host_id_fk"

  add_foreign_key "command_logs", "agents", name: "command_logs_agent_id_fk"
  add_foreign_key "command_logs", "commands", name: "command_logs_command_id_fk"
  add_foreign_key "command_logs", "orgs", name: "command_logs_org_id_fk"

  add_foreign_key "commands", "bundles", name: "commands_bundle_id_fk"
  add_foreign_key "commands", "repos", name: "fk_commands_repos1"

  add_foreign_key "escalation_policies", "on_calls", name: "fk_escalation_policies_on_calls"
  add_foreign_key "escalation_policies", "orgs", name: "fk_escalation_policies_orgs"

  add_foreign_key "host_groups", "host_groups", name: "fk_host_groups_host_groups1", column: "parent_id"
  add_foreign_key "host_groups", "orgs", name: "fk_host_groups_orgs1"

  add_foreign_key "hosts", "orgs", name: "fk_hosts_orgs1"

  add_foreign_key "hosts_host_groups", "host_groups", name: "fk_hosts_host_groups_host_groups1"
  add_foreign_key "hosts_host_groups", "hosts", name: "fk_hosts_host_groups_hosts1"

  add_foreign_key "metric_infos", "commands", name: "fk_command_keys_commands1"

  add_foreign_key "metrics", "checks", name: "fk_metrics_checks1"

  add_foreign_key "on_calls", "orgs", name: "fk_on_calls_orgs"
  add_foreign_key "on_calls", "users", name: "fk_on_calls_users", column: "current_user_id"

  add_foreign_key "orgs", "tenants", name: "fk_orgs_tenants1"

  add_foreign_key "repos", "orgs", name: "fk_repos_orgs1"

  add_foreign_key "resources", "hosts", name: "fk_resources_hosts1"

  add_foreign_key "role_permissions", "permissions", name: "role_permissions_permission_id_fk"
  add_foreign_key "role_permissions", "roles", name: "role_permissions_role_id_fk"

  add_foreign_key "roles", "tenants", name: "roles_tenant_id_fk"

  add_foreign_key "taggings", "tags", name: "fk_taggings_tags1"

  add_foreign_key "trigger_histories", "checks", name: "trigger_histories_check_id_fk"
  add_foreign_key "trigger_histories", "metrics", name: "trigger_histories_metric_id_fk"
  add_foreign_key "trigger_histories", "triggers", name: "trigger_histories_trigger_id_fk"

  add_foreign_key "triggers", "checks", name: "triggers_check_id_fk"
  add_foreign_key "triggers", "metrics", name: "triggers_metric_id_fk"

  add_foreign_key "user_permissions", "permissions", name: "user_permissions_permission_id_fk"
  add_foreign_key "user_permissions", "users", name: "user_permissions_user_id_fk"

  add_foreign_key "users", "orgs", name: "fk_users_orgs1"

  add_foreign_key "users_roles", "roles", name: "users_roles_role_id_fk"
  add_foreign_key "users_roles", "users", name: "users_roles_user_id_fk"

end
