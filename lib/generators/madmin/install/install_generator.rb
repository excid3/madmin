# frozen_string_literal: true


module Madmin
  module Generators
    class InstallGenerator < Rails::Generators::Base
      def generate_resources
        Rails.application.eager_load!
        generateable_models.each do |model|
          puts model
        end
      end

      private

      def generateable_models
        active_record_models.reject do |klass|
          klass.abstract_class? || klass == ActiveRecord::Base
        end
      end

      def active_record_models
        ObjectSpace.each_object(ActiveRecord::Base.singleton_class)
      end
    end
  end
end
