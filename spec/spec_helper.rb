require 'bundler'

Bundler.require :default, :development

Combustion.initialize! :active_record do
  rails_version = Bundler.load.specs['rails'].first.version

  if rails_version >= Gem::Version.new('5') && rails_version < Gem::Version.new('6')
    config.active_record.sqlite3.represent_boolean_as_integer = true
  end
end

require 'bundler/setup'
require 'rspec/rails'
require 'quickery'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

RSpec::Matchers.define_negated_matcher :not_change, :change
