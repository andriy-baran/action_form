# frozen_string_literal: true

module ActionForm
  # Provides DSL methods for defining form schemas and converting them to EasyParams
  module SchemaDSL
    def self.included(base)
      base.extend(ClassMethods)
      base.include(InstanceMethods)
    end

    module ClassMethods # rubocop:disable Style/Documentation
      def params_class
        ActionForm::Params
      end

      def params_definition
        @params_definition ||= create_params_definition
      end

      def params_blocks
        @params_blocks ||= []
      end

      def params(&block)
        params_blocks << block if block
      end

      def inherited_params_blocks
        parent = superclass
        blocks = []
        while parent.respond_to?(:params_blocks)
          parent.params_blocks.each { |block| blocks.unshift(block) }
          parent = parent.superclass
        end
        blocks
      end

      def create_params_definition(elements_definitions: elements) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        schema = Class.new(params_class)
        elements_definitions.each do |name, element_definition|
          if element_definition < ActionForm::SubformsCollection
            # nested forms are passed as a hash that looks like this:
            # { "0" => { "id" => "1" }, "1" => { "id" => "2" } }
            # it is coercing to an array of hashes:
            # [['0', { "id" => "1" }], ['1', { "id" => "2" }]]
            # we need to normalize it to an array of hashes:
            # [ { "id" => "1" }, { "
            # id" => "2" } ]
            schema.each(:"#{name}_attributes", element_definition.subform_definition.params_definition,
                        normalize: ->(value) { value.flatten.select { |v| v.is_a?(Hash) } },
                        default: element_definition.default)
          elsif element_definition < ActionForm::Subform
            schema.has(:"#{name}_attributes", element_definition.params_definition, default: element_definition.default)
          elsif element_definition < ActionForm::Element
            options = element_definition.output_options.dup
            method_name = options.delete(:type)
            schema.public_send(method_name, name, **options)
          end
        end
        patches = inherited_params_blocks + params_blocks
        patches.each do |block|
          schema = Class.new(schema, &block)
        end
        schema.form_class = self
        schema
      end
    end

    module InstanceMethods # rubocop:disable Style/Documentation
      def params_definition
        @params_definition ||= create_params_definition
      end

      def create_params_definition
        schema = Class.new(self.class.params_class)
        schema.form_class = self.class
        renderable_elements = elements_instances.select(&:render?).to_h { |element| [element.name, element.class] }
        self.class.create_params_definition(elements_definitions: renderable_elements)
      end
    end
  end
end
