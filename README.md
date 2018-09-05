# Quickery

## About

* Implements Law of Demeter by mapping associated record attributes as own attributes (one-way read-only)
* Consequently, speeds up SQL queries by removing joins queries between intermediary models, at the cost of slower writes.
* This is an anti-normalization pattern in favour of actual data-redundancy and faster queries. Use this only as necessary.

## Dependencies

* **Rails 4 or 5**
* **(Rails 3 still untested)**

## Setup
1. Add the following to your `Gemfile`:

    ```ruby
    gem 'quickery', '~> 0.1'
    ```

2. Run:

    ```bash
    bundle install
    ```

## Usage Example 1

```ruby
# app/models/employee.rb
class Employee < ApplicationRecord
  # say we have the following attributes:
  #   branch_id:integer
  #   branch_company_name:string
  belongs_to :branch

  quickery do
    # TL;RD: the following line means:
    #   make sure that this record's `branch_company_name` attribute will always have
    #   the same value as branch.company.name and updates the value accordingly if it changes
    branch.company.name == :branch_company_name

    # feel free to rename :branch_company_name as you wish; it's just like any other attribute anyway
    # the == is a custom overloaded operator; it does not mean "is equal" but means "should equal to"
    # branch.company.name is a fluid expression that defines the attribute dependency
    #   `branch` and `company` does not mean `branch` and `company` record

    # you may add more inside this quickery-block: i.e:
    #   branch.name == :branch_name
    #   branch.id == :branch_id
    #   branch.company.country.name == :branch_company_country_name
  end
end

# app/models/branch.rb
class Branch < ApplicationRecord
  # say we have the following attributes:
  #   company_id:integer
  belongs_to :company
end

# app/models/company.rb
class Company < ApplicationRecord
  # say we have the following attributes:
  #   name:string
end
```

```bash
# bash
rails generate migration add_branch_company_name_to_employees branch_company_name:string
bundle exec rake db:migrate
```

```ruby
# rails console
company = Company.create!(name: 'Jollibee')
branch = Branch.create!(company: company)
employee = Employee.create!(branch: branch)

puts employee.branch_company_name
# => 'Jollibee'

# As you can see the `branch_company_name` attribute above has the same value as the associated record's attribute
# Now, let's try updating company, and you will see below that `branch_company_name` automatically gets updated as well

company.update!(name: 'Mang Inasal')

puts employee.branch_company_name
# => 'Jollibee'

# You need to reload the object, if you expect that it's been changed:
employee.reload

puts employee.branch_company_name
# => 'Mang Inasal'

# Now, let's try updating the intermediary association, and you will see below that `branch_company_name` would be updated accordingly
other_company = Company.create!(name: 'McDonalds')
branch.update!(company: other_company)

employee.reload

puts employee.branch_company_name
# => 'McDonalds'
```

## Usage Example 2

* let `Branch` and `Company` model be the same as the Usage Example 1 above

```ruby
# app/models/employee.rb
class Employee < ApplicationRecord
  belongs_to :branch
  belongs_to :country, foreign_key: :branch_company_id

  quickery do
    branch.company.id == :branch_company_id
  end
end
```

```bash
# bash
rails generate migration add_branch_company_id_to_employees branch_company_id:bigint
bundle exec rake db:migrate
```

```ruby
# rails console
company = Company.create!(name: 'Jollibee')
branch = Branch.create!(company: company)
employee = Employee.create!(branch: branch)

puts employee.branch_company_id
# => 1

puts Employee.where(company: company)
# => [#<Employee id: 1>]

# as you may notice, the query above is a lot simpler and faster instead of doing it normally like below (if not using Quickery)
# you may however still using belongs_to `:through` to achieve the simplified query like above, but it's still a lot slower because of JOINS
puts Employee.joins(branch: :company).where(companies: { id: company.id })
```

## DSL

### For any subclass of `ActiveRecord::Base`:

#### Class Methods:

##### `quickery(&block)`
* returns a `Quickery::AssociationBuilder` object
* block is executed in the context of the `Quickery::AssociationBuilder` object,
  which means that you cannot access the model instance inside the block, as you are not supposed to.
* inside the block you may define "quickery-defined attribute mappings";
  each mapping will create a `Quickery::QuickeryBuilder` object. i.e:
    * `branch.company.country.category.name == :some_attribute_in_this_model`
    * You are required to specify `belongs_to :branch` association in this model.
    * Similarly, you are required to specify `belongs_to :company` inside `Branch` model, `belongs_to :country` inside `Company` model; etc...
##### `quickery_builders`
* returns an `Array` of `Quickery::QuickeryBuilder` objects that have already been defined
* for more info, see `quickery(&block)` above
* you normally do not need to use this method

#### Instance Methods:

##### `recreate_quickery_cache!`
* force-updates the quickery-defined attributes
* useful if you already have records, and you want these old records to be updated immediately
* i.e. you can do so something like the following:
    ```ruby
    # rails console
    Employee.each do |employee|
      employee.recreate_quickery_cache!
    end
    ```

##### `determine_quickery_value(depender_column_name)`
* returns the current "actual" supposed value of the "original" dependee column
* useful for debugging to check if the quickery-defined attributes do not have correct mapped values
* i.e. you can do something like the following:

    ```ruby
    employee = Employee.first
    puts employee.determine_quickery_value(:branch_company_country_name)
    # => 'Ireland'
    ```

## TODOs
* Possibly support two-way mapping of attributes? So that you can do, say... `employee.update!(branch_company_name: 'somenewcompanyname')`

## Contributing
* pull requests and forks are very much welcomed! :) Let me know if you find any bug! Thanks

## License
* MIT

## Developer Guide
* see [developer_guide.md](developer_guide.md)

## Changelog
* 0.1.0
  * initial beta release
