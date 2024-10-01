module Madmin
  class Field
    attr_reader :attribute_name, :model, :options, :resource

    def self.field_type
      to_s.split("::").last.underscore
    end

    def initialize(attribute_name:, model:, resource:, options:)
      @attribute_name = attribute_name.to_sym
      @model = model
      @resource = resource
      @options = options
    end

    def value(record)
      record.public_send(attribute_name)
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

    # Used for checking visibility of attribute on an view
    def visible?(action)
      action = action.to_sym
      options.fetch(action) do
        case action
        when :index
          default_index_attributes.include?(attribute_name)
        when :new, :create, :edit, :update
          # Hidden attributes for forms
          [:id, :created_at, :updated_at].exclude?(attribute_name)
        else
          true
        end
      end
    end

    def default_index_attributes
      [model.primary_key.to_sym, :avatar, :title, :name, :user]
    end

    def required?
      model.validators_on(attribute_name).any? { |v| v.is_a? ActiveModel::Validations::PresenceValidator }
    end

    def searchable?
      false
    end
  end
end
