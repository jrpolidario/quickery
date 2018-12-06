require 'rails/generators/active_record'

module Quickery
  module Generators
    class MigrationGenerator < ActiveRecord::Generators::Base
      desc 'Generate migration for quickery attributes'
      source_root File.expand_path('../templates', __FILE__)

      argument :attributes, required: true, type: :array, desc: 'The quickery-attributes',
        banner: 'company_name:string company_country_id:integer company_country_name:string ...'

      class_option :add_is_synced_attributes, desc: 'Add extra `*_is_synced` attribute per quickery-attribute', default: nil

      def generate_migration
        migration_template("migration.rb.erb",
                           "db/migrate/#{migration_file_name}.rb",
                           migration_version: migration_version)
      end

      def migration_name
        "add_quickery_#{attributes.map(&:name).join("_")}_to_#{name.underscore.pluralize}"
      end

      def migration_file_name
        "#{migration_name}"
      end

      def migration_class_name
        migration_name.camelize
      end

      def migration_version
        if Rails.version.start_with? "5"
          "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
        end
      end

      # https://github.com/rails/rails/blob/v5.2.1/activerecord/lib/rails/generators/active_record/migration/migration_generator.rb#L62
      def attributes_with_index
        attributes.select { |a| !a.reference? && a.has_index? }
      end
    end
  end
end
