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

## Usage Example

  ```ruby
  # app/models/employee.rb
  class Employee < ApplicationRecord
    # say we have the following attributes:
    #   branch_id:integer
    #   branch_company_name:string
    belongs_to :branch

    # feel free to rename :branch_company_name as you wish; it's just like any other attribute anyway
    quickery do
      branch.company.name == :branch_company_name
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
