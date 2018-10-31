# Quickery

[![Build Status](https://travis-ci.org/jrpolidario/quickery.svg?branch=master)](https://travis-ci.org/jrpolidario/quickery)
[![Gem Version](https://badge.fury.io/rb/quickery.svg)](https://badge.fury.io/rb/quickery)

* Implements Law of Demeter by mapping associated record attributes as own attributes (one-way read-only)
* Consequently, speeds up SQL queries by removing joins queries between intermediary models, at the cost of slower writes.
* This is an anti-normalization pattern in favour of actual data-redundancy and faster queries. Use this only as necessary.

## Dependencies

* **Rails 4 or 5**
* **(Rails 3 still untested)**
* `ActiveRecord`

## Setup
1. Add the following to your `Gemfile`:

    ```ruby
    gem 'quickery', '~> 1.0'
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
  #   branch_id:bigint
  #   branch_company_name:string

  belongs_to :branch

  # TL;DR: the following line means:
  #   make sure that this record's `branch_company_name` attribute will always have the same value as
  #   branch.company.name and auto-updates the value if it (or any associated record in between) changes

  quickery branch: { company: { name: :branch_company_name } }

  # feel free to rename :branch_company_name as you wish; it's just like any other attribute anyway
end

# app/models/branch.rb
class Branch < ApplicationRecord
  # say we have the following attributes:
  #   company_id:bigint

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

# You may or may not need to reload the object, depending on if you expect that it's been changed:
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

If you already have "old" records before you've integrated quickery or if you have new quickery-defined attributes, you can update these stale records by using `recreate_quickery_cache!`. See example below:

```ruby
# rails console
Employee.find_each do |employee|
  employee.recreate_quickery_cache!
end
```

## Usage Example 2

* let `Branch` and `Company` model be the same as the Usage Example 1 above

```ruby
# app/models/employee.rb
class Employee < ApplicationRecord
  belongs_to :branch
  belongs_to :company, foreign_key: :branch_company_id, optional: true

  quickery { branch: { company: { id: :branch_company_id } } }
end
```

```bash
# bash
rails generate migration add_branch_company_id_to_employees branch_company_id:bigint:index
bundle exec rake db:migrate
```

```ruby
# rails console
company = Company.create!(name: 'Jollibee')
branch = Branch.create!(company: company)
employee = Employee.create!(branch: branch)

puts employee.branch_company_id
# => 1

puts employee.company
# => #<Company id: 1 name: 'Jollibee'>

puts Employee.where(company: company)
# => [#<Employee id: 1>]

# as you may notice, the query above is a lot simpler and faster instead of doing it normally like below (if not using Quickery)
# you may however still use `has_many :through` to achieve a simplified code: `company.employees`, but it's still a lot slower because of JOINS
puts Employee.joins(branch: :company).where(companies: { id: company.id })
# => [#<Employee id: 1>]
```

## Other Usage Examples

```ruby
# app/models/employee.rb
class Employee < ApplicationRecord
  # multiple-attributes and/or multiple-associations; as many, and as deep as you wish
  quickery(
    branch: {
      name: :branch_name,
      address: :branch_address,
      company: {
        name: :branch_company_name
      }
    },
    user: {
      first_name: :user_first_name,
      last_name: :user_last_name
    }
  )
end
```

```ruby
# app/models/employee.rb
class Employee < ApplicationRecord
  # `quickery` can be called multiple times
  quickery { branch: { name: :branch_name } }
  quickery { branch: { address: :branch_address } }
  quickery { branch: { company: { name: :branch_company_name } } }
  quickery { user: { first_name: :user_first_name } }
  quickery { user: { last_name: :user_last_name } }
end
```

## Gotchas
* Quickery makes use of Rails model callbacks such as `before_save`. This meant that data-integrity holds unless `update_columns` or `update_column` is used which bypasses model callbacks, or unless any manual SQL update is performed.
* Quickery does not automatically update old records existing in the database that were created before you integrate Quickery, or before you add new/more Quickery-attributes for that model. One solution is [`recreate_quickery_cache!`](#recreate_quickery_cache) below.

## DSL

### For any subclass of `ActiveRecord::Base`:

* defines a set of "hidden" Quickery `before_create`, `before_update`, and `before_destroy` callbacks needed by Quickery to perform the "syncing" of attribute values

#### Class Methods:

##### `quickery(mappings)`
* mappings (Hash)
  * each mapping will create a `Quickery::QuickeryBuilder` object. i.e:
    * `{ branch: { name: :branch_name }` will create one `Quickery::QuickeryBuilder`, while
    * `{ branch: { name: :branch_name, id: :branch_id }` will create two `Quickery::QuickeryBuilder`
        * In this particular example, you are required to specify `belongs_to :branch` in this model
        * Similarly, you are required to specify `belongs_to :company` inside `Branch` model, `belongs_to :country` inside `Company` model; etc...
* defines a set of "hidden" Quickery `before_save`, `before_update`, `before_destroy`, and `before_create` callbacks across all models specified in the quickery-defined attribute association chain.
* quickery-defined attributes such as say `:branch_company_country_category_name` are updated by Quickery automatically whenever any of it's dependent records across models have been changed. Note that updates in this way do not trigger model callbacks, as I wanted to isolate logic and scope of Quickery by not triggering model callbacks that you already have.
* quickery-defined attributes such as say `:branch_company_country_category_name` are READ-only! Do not update these attributes manually. You can, but it will not automatically update the other end, and thus will break data integrity. If you want to re-update these attributes to match the other end, see `recreate_quickery_cache!` below.

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
    Employee.find_each do |employee|
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
* Support `has_many` as currently only `belongs_to` is supported. This would then allow us to cache Array of values.
* Support custom-methods-values like [`persistize`](https://github.com/bebanjo/persistize), if it's easy enough to integrate something similar
* Support background-processing like in [`flattery`](https://github.com/evendis/flattery)

## Other Similar Gems
See [my detailed comparisons](other_similar_gems_comparison.md)

* [persistize](https://github.com/bebanjo/persistize)
* [activerecord-denormalize](https://github.com/ursm/activerecord-denormalize)
* [flattery](https://github.com/evendis/flattery)

## License
* MIT

## Developer Guide
* see [developer_guide.md](developer_guide.md)

## Contributing
* pull requests and forks are very much welcomed! :) Let me know if you find any bug! Thanks

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request

## Changelog
* 1.0.0
  * Done (TODO): DSL changed from quickery (block) into quickery (hash). Thanks to @xire28 and @sshaw_ in my [reddit post](https://www.reddit.com/r/ruby/comments/9dlcc5/i_just_published_a_new_gem_quickery_an/) for the suggestion.
  * Done (TODO): Now updates in one go, instead of updating record per quickery-attribute, thereby greatly improving speed.
* 0.1.4
  * add `railstie` as dependency to fix undefined constant error
* 0.1.3
  * fixed Quickery not always working properly because of Rails autoloading; fixed by eager loading all Models (`app/models/*/**/*.rb`)
* 0.1.2
  * fixed require error for remnant debugging code: 'byebug'
* 0.1.1
  * Gemspec fixes and travis build fixes.
* 0.1.0
  * initial beta release
