# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_table 'categories', force: :cascade do |t|
    t.string 'name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'countries', force: :cascade do |t|
    t.string 'name'
    t.bigint 'category_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['category_id'], name: 'index_countries_on_category_id'
  end

  create_table 'companies', force: :cascade do |t|
    t.string 'name'
    t.bigint 'country_id'
    t.bigint 'category_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['country_id'], name: 'index_companies_on_country_id'
    t.index ['category_id'], name: 'index_companies_on_category_id'
  end

  create_table 'branches', force: :cascade do |t|
    t.string 'name'
    t.bigint 'company_id'
    t.bigint 'category_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['company_id'], name: 'index_branches_on_company_id'
    t.index ['category_id'], name: 'index_branches_on_category_id'
  end

  create_table 'employees', force: :cascade do |t|
    t.string 'name'
    t.bigint 'branch_id'
    t.bigint 'category_id'
    t.string 'branch_company_country_name'
    t.boolean 'branch_company_country_name_is_synced', null: false, default: false
    t.string 'branch_company_name'
    t.boolean 'branch_company_name_is_synced', null: false, default: false
    t.integer 'branch_company_country_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['branch_id'], name: 'index_employees_on_branch_id'
    t.index ['category_id'], name: 'index_employees_on_category_id'
  end

  add_foreign_key 'employees', 'branches'
  add_foreign_key 'employees', 'categories'
  add_foreign_key 'branches', 'companies'
  add_foreign_key 'branches', 'categories'
  add_foreign_key 'companies', 'countries'
  add_foreign_key 'companies', 'categories'
  add_foreign_key 'countries', 'categories'
end
