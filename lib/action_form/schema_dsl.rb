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
        EasyParams::Base
      end

      def params_definition(*)
        @params_definition ||= create_params_definition
      end

      def params(&block)
        @params_definition = create_params_definition(&block)
        @params_definition.class_eval(&block) if block
      end

      def create_params_definition # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        schema = Class.new(params_class)
        elements.each do |name, element_definition|
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
        schema
      end
    end

    module InstanceMethods # rubocop:disable Style/Documentation
      def params_definition(*)
        @params_definition ||= create_params_definition
      end

      def create_params_definition # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        schema = Class.new(self.class.params_class)
        elements_instances.select(&:render?).each do |element|
          case element
          when ActionForm::SubformsCollection
            # nested forms are passed as a hash that looks like this:
            # { "0" => { "id" => "1" }, "1" => { "id" => "2" } }
            # it is coercing to an array of hashes:
            # [['0', { "id" => "1" }], ['1', { "id" => "2" }]]
            # we need to normalize it to an array of hashes:
            # [ { "id" => "1" }, { "
            # id" => "2" } ]
            schema.each(:"#{element.name}_attributes", element.subforms.first.params_definition,
                        normalize: ->(value) { value.flatten.select { |v| v.is_a?(Hash) } },
                        default: element.class.default)
          when ActionForm::Subform
            schema.has(:"#{element.name}_attributes", element.params_definition, default: element.class.default)
          when ActionForm::Element
            options = element.class.output_options.dup
            method_name = options.delete(:type)
            schema.public_send(method_name, element.name, **options)
          end
        end
        schema
      end
    end
  end
end
