module Madmin
  class ResourceBuilder
    attr_reader :model

    def initialize(model)
      @model = model
    end

    def associations
      model.reflections.reject { |name, association|
        # Hide these special associations
        name.starts_with?("rich_text") ||
          name.ends_with?("_attachment") ||
          name.ends_with?("_attachments") ||
          name.ends_with?("_blob") ||
          name.ends_with?("_blobs")
      }.keys
    end

    def attributes
      model.attribute_names + virtual_attributes - redundant_attributes
    end

    def store_accessors
      model.stored_attributes.values.flatten
    end

    def virtual_attributes
      virtual = []

      # has_secure_password columns
      password_attributes = model.attribute_types.keys.select { |k| k.ends_with?("_digest") }.map { |k| k.delete_suffix("_digest") }
      virtual += password_attributes.map { |attr| [attr, "#{attr}_confirmation"] }.flatten

      # ActiveRecord Store columns
      virtual += store_accessors.map(&:to_s)

      # Add virtual attributes for ActionText and ActiveStorage
      model.reflections.each do |name, association|
        if name.starts_with?("rich_text")
          virtual << name.split("rich_text_").last
        elsif name.ends_with?("_attachment")
          virtual << name.split("_attachment").first
        elsif name.ends_with?("_attachments")
          virtual << name.split("_attachments").first
        end
      end

      virtual
    end

    def redundant_attributes
      redundant = []

      # has_secure_password columns
      redundant += model.attribute_types.keys.select { |k| k.ends_with?("_digest") }

      # ActiveRecord Store columns
      store_columns = model.stored_attributes.keys
      redundant += store_columns.map(&:to_s)

      model.reflections.each do |name, association|
        if association.has_one?
          next
        elsif association.collection?
          next
        elsif association.polymorphic?
          redundant << "#{name}_id"
          redundant << "#{name}_type"
        elsif name.starts_with?("rich_text")
          redundant << name
        else # belongs to
          redundant << "#{name}_id"
        end
      end

      redundant
    end
  end
end
