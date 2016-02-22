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

ActiveRecord::Schema.define(version: 20160222090932) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "postgis_topology"

  create_table "address_blocks", force: :cascade do |t|
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "start_idx",        limit: 8, null: false
    t.integer  "end_idx",          limit: 8, null: false
    t.text     "place_attributes"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "address_blocks", ["source_type", "source_id"], name: "index_address_blocks_on_source_type_and_source_id", using: :btree

  create_table "documents", force: :cascade do |t|
    t.integer  "local_administration_unit_id"
    t.string   "title",                        limit: 512
    t.string   "url",                          limit: 2048
    t.string   "reference_url",                limit: 2048
    t.string   "edesky_plain_text_url",        limit: 2048
    t.datetime "from_date"
    t.string   "document_storage_uid",         limit: 2048
    t.string   "document_storage_name",        limit: 2048
    t.string   "document_storage_mime_type"
    t.string   "document_storage_size"
    t.string   "text_storage_uid",             limit: 2048
    t.string   "text_storage_name",            limit: 2048
    t.string   "text_storage_mime_type"
    t.string   "text_storage_size"
    t.integer  "edesky_attachment_id",         limit: 8
    t.integer  "edesky_document_id",           limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                                     default: "created", null: false
    t.string   "message"
    t.datetime "parsed_at"
    t.datetime "plain_text_at"
  end

  add_index "documents", ["document_storage_name"], name: "index_documents_on_document_storage_name", using: :btree
  add_index "documents", ["document_storage_uid"], name: "index_documents_on_document_storage_uid", using: :btree
  add_index "documents", ["edesky_attachment_id"], name: "index_documents_on_edesky_attachment_id", using: :btree
  add_index "documents", ["edesky_document_id"], name: "index_documents_on_edesky_document_id", using: :btree
  add_index "documents", ["local_administration_unit_id"], name: "index_documents_on_local_administration_unit_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "address_block_id"
    t.integer  "address_block_idx"
    t.integer  "shape_id"
    t.boolean  "display",           default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["source_type", "source_id"], name: "index_events_on_source_type_and_source_id", using: :btree

  create_table "income_email_addresses", force: :cascade do |t|
    t.string   "email",                        null: false
    t.integer  "created_by_id",                null: false
    t.integer  "local_administration_unit_id"
    t.text     "description"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "income_email_addresses", ["local_administration_unit_id"], name: "index_income_email_addresses_on_local_administration_unit_id", using: :btree

  create_table "local_administration_unit_admins", force: :cascade do |t|
    t.integer  "local_administration_unit_id"
    t.integer  "user_id"
    t.string   "role"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "local_administration_unit_admins", ["local_administration_unit_id"], name: "las_admins_on_las_id", using: :btree
  add_index "local_administration_unit_admins", ["user_id"], name: "index_local_administration_unit_admins_on_user_id", using: :btree

  create_table "local_administration_units", force: :cascade do |t|
    t.integer  "ruian_locable_id"
    t.string   "ruian_locable_type"
    t.integer  "edesky_dashboard_id", limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "local_administration_units", ["edesky_dashboard_id"], name: "index_local_administration_units_on_edesky_dashboard_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.string   "message"
    t.integer  "user_id"
    t.decimal  "lng",               precision: 9, scale: 6
    t.decimal  "lat",               precision: 9, scale: 6
    t.integer  "distance"
    t.datetime "last_send_by_mail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

# Could not dump table "shapes" because of following StandardError
#   Unknown type 'geometry' for column 'definition_point'

  create_table "spatial_ref_sys", primary_key: "srid", force: :cascade do |t|
    t.string  "auth_name", limit: 256
    t.integer "auth_srid"
    t.string  "srtext",    limit: 2048
    t.string  "proj4text", limit: 2048
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "role",                   default: "", null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "income_email_addresses", "local_administration_units"
  add_foreign_key "local_administration_unit_admins", "local_administration_units"
  add_foreign_key "local_administration_unit_admins", "users"
end
