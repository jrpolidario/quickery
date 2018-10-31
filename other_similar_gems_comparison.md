# Quickery
## Other Similar Gems Comparison

* [persistize v0.5.0](https://github.com/bebanjo/persistize) :
  * Pros against Quickery:
    * Flexible custom methods / dependencies
    * supports `has_many` and `belongs_to` while Quickery only supports `belongs_to` (currently)
  * Cons against Quickery:
    * It is not documented, but you'll need to do `Rails.application.eager_load!` first or something similar, to first load all the models as otherwise defined `persistize` across the models will be autoloaded, and therefore will not work properly. Quickery already does this eager loading of models out of the box. For more info, see [lib/quickery/railtie.rb](lib/quickery/railtie.rb)
    * batch-update in one go for multiple quickery-defined attributes instead of updating each attribute/method
    * loops through each children records and update each attribute which can get very slow with lots of children associated records, and therefore as many number of SQL UPDATE queries vs Quickery which uses `update_all` which is just one update query, and does not loop through children records:

      ```ruby
      # app/models/project.rb
      class Project < ActiveRecord::Base
        has_many :tasks
      end

      # app/models/task.rb
      class Task < ActiveRecord::Base
        belongs_to :project

        def project_name
          project.name
        end

        persistize :project_name, depending_on: :project
      end

      # rails console
      project = Project.create(name: 'someproject')
      task_1 = Task.create(project: project)
      task_2 = Task.create(project: project)

      project.update(name: 'newprojectname')
      # for as many number of tasks records that belongs to the `project` above, the `update` above will also have the same number of SQL update queries, and can be very slow:
      # SQL (0.1ms) UPDATE "tasks" SET "project_name" = $1 WHERE "tasks"."id" = $2 [["project_name", "newprojectname"], ["id", 1]]
      # SQL (0.1ms) UPDATE "tasks" SET "project_name" = $1 WHERE "tasks"."id" = $2 [["project_name", "newprojectname"], ["id", 2]]
      ```

    * because you are using custom methods in persistize, every time you update any of the `depending_on` records, the methods you defined are executed even if the updated attribute/s are not depended upon by the methods: i.e. extending from `persistize` github page:

      ```ruby
      # app/models/project.rb
      class Project < ActiveRecord::Base
        has_many :tasks
      end

      # app/models/task.rb
      class Task < ActiveRecord::Base
        belongs_to :project

        def project_name
          puts "Task(id: #{id}) project_name has been executed"
          project.name
        end

        persistize :project_name, depending_on: :project
      end

      # rails console
      project = Project.create(name: 'someproject')
      task_1 = Task.create(project: project)
      task_2 = Task.create(project: project)

      project.update(someotherattribute: 'somevalue')
      # => Task(id: 1) project_name has been executed
      # => Task(id: 2) project_name has been executed
      ```

    * does not support nested associated dependencies for `belongs_to`, but only supports for nested associated dependencies for `has_many` (if using `through: `):

      ```ruby
      # app/models/project.rb
      class Project < ActiveRecord::Base
        has_many :tasks
      end

      # app/models/task.rb
      class Task < ActiveRecord::Base
        belongs_to :project
        has_many :subtasks
      end

      # app/models/subtask.rb
      class Subtask < ActiveRecord::Base
        belongs_to :task

        def task_name
          task.name
        end

        def task_project_name
          task.project.name
        end

        # works as expected:
        persistize :task_name, :depending_on => [:task]
        # not supported:
        persistize :task_project_name, :depending_on => { task: :project }
      end
      ```

* [activerecord-denormalize v0.2.0](https://github.com/ursm/activerecord-denormalize) :
  * Pros against Quickery:
    * *possibly there are pros, but because I could not test this because it seems to not support Rails 4 and 5 (see cons below)*
  * Cons against Quickery:
    * Rails 5 seems to be not supported (most likely because last commit was 6 years ago). I was getting `Gem Load Error is: wrong number of arguments (given 0, expected 1)` when doing `rails g model message sender:references{polymorphic} _sender:hstore`
    * Rails 4 seems to be also not supported. I was getting `ArgumentError (wrong number of arguments (given 1, expected 0))` when doing `User.create` inside rails console.

* [flattery v0.1.0](https://github.com/evendis/flattery) :
  * Pros against Quickery:
    * allows custom update method
    * allows "updates" as a background process
  * Cons against Quickery:
    * Rails 5 is not part of its supported list in their github page. And just to try it out on a Rails 5 app, `Flattery::ValueProvider` did not seem to work, because values are not pushed to the `:notes`'s `:category_name` values.
    * batch-update in one go for multiple quickery-defined attributes instead of updating each
    * Using Rails 4, does not support nested associated dependencies for `belongs_to`:

      ```ruby
      class Note < ActiveRecord::Base
        belongs_to :category, :inverse_of => :notes

        include Flattery::ValueCache
        # one-level works:
        flatten_value category: :name
        # nested not supported:
        flatten_value category: { user: :email }
      end
      ```
