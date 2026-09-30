module Madmin
  class Field
    attr_reader :attribute_name, :model, :options, :resource

    def self.field_type
      to_s.split("::").last.underscore
    end

    # The kind of index filter a field offers (:string, :number, :date,
    # :datetime or :boolean), or nil for none
    def self.filter_type
    end

    def initialize(attribute_name:, model:, resource:, options:)
      @attribute_name = attribute_name.to_sym
      @model = model
      @resource = resource
      @options = options
    end

    def value(record)
      record.try(attribute_name)
    end

    def to_partial_path(name)
      unless %w[index show form].include? name.to_s
        raise ArgumentError, "`partial` must be 'index', 'show', or 'form'"
      end

      "/madmin/fields/#{self.class.field_type}/#{name}"
    end

    def to_param
      attribute_name
    end

    # Converts the submitted form value into the value assigned to the record
    def cast(value)
      value
    end

    # Whether the value returned by `cast` can be saved. The form is shown again with an error when it can't.
    def accepts?(value)
      true
    end

    def label
      options[:label].presence || model.human_attribute_name(attribute_name)
    end

    # Used for checking visibility of attribute on an view
    def visible?(action)
      action = action.to_sym
      options.fetch(action) do
        case action
        when :index
          default_index_attributes.include?(attribute_name)
        else
          true
        end
      end
    end

    def default_index_attributes
      [model.primary_key.to_sym, :avatar, :title, :name, :user, :created_at]
    end

    def required?
      model.validators_on(attribute_name).any? { |v| v.is_a? ActiveModel::Validations::PresenceValidator }
    end

    def searchable?
      false
    end

    def paginateable?
      false
    end

    # Only database columns can be filtered, and not encrypted ones since their
    # stored values can't be compared. `filter: false` turns it off
    def filter_type
      if options.fetch(:filter, true) && resource.model_column_names.include?(attribute_name.to_s) && !model.try(:encrypted_attributes)&.include?(attribute_name)
        self.class.filter_type
      end
    end

    ActiveSupport.run_load_hooks(:madmin_field, self)
  end
end
