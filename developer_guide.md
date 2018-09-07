## Development

### Publishing as Ruby Gem

```bash
# [increment gem VERSION]
gem build quickery
gem push quickery-X.X.X.gem
```

## Test

* Test suite makes use of the following gems worth mentioning (in addition to some others):
  * [rspec-rails](https://github.com/rspec/rspec-rails)
  * [combustion](https://github.com/pat/combustion)
  * [appraisal](https://github.com/thoughtbot/appraisal)

### Setup

```bash
# setup development gems
bundle install
# setup Apprisal for testing different Rails versions below
bundle exec appraisal install
```

```bash
# to auto-test specs whenever a spec file has been modified:
bundle exec guard

# to manually run specs for a particular rails version (for more info: see Appraisals file):
bundle exec appraisal rails-5 rspec
# or
bundle exec appraisal rails-4 rspec
```
