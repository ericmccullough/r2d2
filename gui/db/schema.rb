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

ActiveRecord::Schema.define(version: 20170313024151) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "devices", force: :cascade do |t|
    t.string   "mac"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "list_id"
    t.string   "notes"
    t.integer  "fingerprint"
  end

  add_index "devices", ["list_id"], name: "index_devices_on_list_id", using: :btree

  create_table "fingerprints", force: :cascade do |t|
    t.string   "tcp_ports"
    t.string   "udp_ports"
    t.string   "shares"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
  end

  create_table "glyphs", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "leases", force: :cascade do |t|
    t.string   "ip"
    t.string   "mask"
    t.string   "expiration"
    t.string   "kind"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "scope_id"
    t.integer  "device_id"
  end

  add_index "leases", ["device_id"], name: "index_leases_on_device_id", using: :btree
  add_index "leases", ["scope_id"], name: "index_leases_on_scope_id", using: :btree

  create_table "lists", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "glyph_id"
  end

  add_index "lists", ["glyph_id"], name: "index_lists_on_glyph_id", using: :btree

  create_table "nodes", force: :cascade do |t|
    t.string   "mac"
    t.string   "ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "results", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "node_id"
    t.integer  "sweep_id"
  end

  create_table "scopes", force: :cascade do |t|
    t.string   "ip"
    t.string   "mask"
    t.string   "leasetime"
    t.string   "description"
    t.string   "comment"
    t.string   "state"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "server_id"
  end

  add_index "scopes", ["server_id"], name: "index_scopes_on_server_id", using: :btree

  create_table "servers", force: :cascade do |t|
    t.string   "name"
    t.string   "ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sweepers", force: :cascade do |t|
    t.string   "ip"
    t.string   "mac"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "sweeps", force: :cascade do |t|
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "description"
  end

  create_table "vendors", force: :cascade do |t|
    t.string   "oui"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "devices", "lists"
  add_foreign_key "leases", "devices"
  add_foreign_key "leases", "scopes"
  add_foreign_key "lists", "glyphs"
  add_foreign_key "scopes", "servers"
end
