require "madmin/generator_helpers"

module Madmin
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Madmin::GeneratorHelpers

      source_root File.expand_path("../templates", __FILE__)

      def eager_load
        Rails.application.eager_load!
      end

      def copy_controller
        template("controller.rb.tt", "app/controllers/madmin/application_controller.rb")
      end

      def generate_routes
        if route_namespace_exists?
          route "root to: \"dashboard#show\"", indentation: 4, sentinel: /namespace :madmin do\s*\n/m
        else
          route "root to: \"dashboard#show\"", namespace: [:madmin]
        end
      end

      def generate_resources
        generateable_models.each do |model|
          if model.table_exists?
            call_generator "madmin:resource", model.to_s
          else
            puts "Skipping #{model} because database table does not exist"
          end
        end
      end

      private

      # Skip Abstract classes, ActiveRecord::Base, and auto-generated HABTM models
      def generateable_models
        active_record_models.reject do |model|
          model.abstract_class? || model == ActiveRecord::Base || model.name.start_with?("HABTM_")
        end
      end

      def active_record_models
        ObjectSpace.each_object(ActiveRecord::Base.singleton_class)
      end
    end
  end
end
