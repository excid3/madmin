module Madmin
  class Field
    attr_reader :attribute_name

    def self.field_type
      to_s.split("::").last.underscore
    end

    def initialize(attribute_name:, **options)
      @attribute_name = attribute_name
    end

    def value(record)
      record.public_send(attribute_name)
    end

    def to_partial_path(name)
      unless %w[index show form].include? name
        raise ArgumentError, "`partial` must be 'index', 'show', or 'form'"
      end

      "/madmin/fields/#{self.class.field_type}/#{name}"
    end

    def to_param
      attribute_name
    end
  end
end
