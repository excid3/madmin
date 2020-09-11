require "madmin/generator_helpers"

module Madmin
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Madmin::GeneratorHelpers

      def eager_load
        Rails.application.eager_load!
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

      def generateable_models
        active_record_models.reject do |model|
          model.abstract_class? || model == ActiveRecord::Base
        end
      end

      def active_record_models
        ObjectSpace.each_object(ActiveRecord::Base.singleton_class)
      end
    end
  end
end
