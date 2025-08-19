# frozen_string_literal: true

module EasyForm
  # Provides DSL methods for defining form schemas and converting them to EasyParams
  module SchemaDSL
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods # rubocop:disable Style/Documentation
      def schema_definition # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        schema = Class.new(EasyParams::Base)
        forms.each do |name, form_definition|
          if form_definition.is_a?(Array)
            schema.public_send(:each, :"#{name}_attributes", form_definition.first.schema_definition)
          else
            schema.public_send(:has, :"#{name}_attributes", form_definition.schema_definition)
          end
        end
        elements.each do |name, element_definition|
          options = element_definition.output_options.dup
          method_name = options.delete(:type)
          schema.public_send(method_name, name, **options)
        end
        schema
      end
      alias params_definition schema_definition
    end
  end
end
