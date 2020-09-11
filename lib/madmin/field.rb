module Madmin
  class Field
    attr_reader :record, :attribute_name, :partial

    def self.field_type
      to_s.split("::").last.underscore
    end

    def initialize(record:, attribute_name:, partial:)
      unless %w{ index show form }.include? partial
        raise ArgumentError, "`partial` must be 'index', 'show', or 'form'"
      end

      @record = record
      @attribute_name = attribute_name
      @partial = partial
    end

    def value
      record.public_send(attribute_name)
    end

    def to_partial_path
      "/madmin/fields/#{self.class.field_type}/#{partial}"
    end
  end
end
