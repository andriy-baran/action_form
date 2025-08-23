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
        elements.each do |name, element_definition|
          if element_definition.is_a?(Array)
            # nested forms are passed as a hash that looks like this:
            # { "0" => { "id" => "1" }, "1" => { "id" => "2" } }
            # it is coercing to an array of hashes:
            # [['0', { "id" => "1" }], ['1', { "id" => "2" }]]
            # we need to normalize it to an array of hashes:
            # [ { "id" => "1" }, { "id" => "2" } ]
            schema.each(:"#{name}_attributes", element_definition.first.schema_definition,
                        normalize: ->(value) { value.flatten.select { |v| v.is_a?(Hash) } })
          elsif element_definition < EasyForm::Subform
            schema.has(:"#{name}_attributes", element_definition.schema_definition)
          elsif element_definition < EasyForm::Element
            options = element_definition.output_options.dup
            method_name = options.delete(:type)
            schema.public_send(method_name, name, **options)
          end
        end
        schema
      end
      alias params_definition schema_definition
    end
  end
end
