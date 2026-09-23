# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_23_200000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "ag_catalog.age"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vector"

  create_table "chat_questions", force: :cascade do |t|
    t.text "assuntos_consultados"
    t.datetime "created_at", null: false
    t.text "erro"
    t.text "question", null: false
    t.text "resposta"
    t.integer "status", default: 0, null: false
    t.jsonb "tool_calls", default: [], null: false
    t.datetime "updated_at", null: false
  end

  create_table "question_question_subjects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "question_id", null: false
    t.bigint "subject_id", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_question_question_subjects_on_question_id"
    t.index ["subject_id"], name: "index_question_question_subjects_on_subject_id"
  end

  create_table "question_questions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "titulo"
    t.datetime "updated_at", null: false
  end

  create_table "subject_subject_prerequisites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "prerequisite_id", null: false
    t.bigint "subject_id", null: false
    t.datetime "updated_at", null: false
    t.index ["prerequisite_id"], name: "index_subject_subject_prerequisites_on_prerequisite_id"
    t.index ["subject_id"], name: "index_subject_subject_prerequisites_on_subject_id"
  end

  create_table "subject_subjects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "nome"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "question_question_subjects", "question_questions", column: "question_id"
  add_foreign_key "question_question_subjects", "subject_subjects", column: "subject_id"
  add_foreign_key "subject_subject_prerequisites", "subject_subjects", column: "prerequisite_id"
  add_foreign_key "subject_subject_prerequisites", "subject_subjects", column: "subject_id"
end
