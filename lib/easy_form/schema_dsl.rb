# frozen_string_literal: true

module EasyForm
  # Provides DSL methods for defining form schemas and converting them to EasyParams
  module SchemaDSL
    def self.included(base)
      base.extend(ClassMethods)
      base.include(InstanceMethods)
    end

    module ClassMethods # rubocop:disable Style/Documentation
      def hash_to_dsl(hash) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        lines = []

        hash.each do |type, value|
          case type
          when :each, :has
            value.each do |collection_name, nested_hash|
              lines << "#{type} :#{collection_name} do"
              lines.concat(hash_to_dsl(nested_hash))
              lines << "end"
            end
          else
            attribute_name, options = value
            options_str = options.map { |k, v| "#{k}: #{v.inspect}" }.join(",") if options.is_a?(Hash)
            lines << "#{type} #{[":#{attribute_name}", options_str].compact.join(", ")}"
          end
        end

        lines
      end

      def hash_to_dsl_string(hash)
        hash_to_dsl(hash).join("\n")
      end
    end

    module InstanceMethods # rubocop:disable Style/Documentation
      def schema_definition
        @schema_definition ||= Class.new(EasyParams::Base).tap do |schema|
          schema.class_eval(self.class.hash_to_dsl_string(traverse_hash))
        end
      end

      def traverse_hash # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        data = elements.each_with_object({}) do |(name, element), value|
          options = element.output_options.dup
          method_name = options.delete(:type)

          value[method_name] = [name, options]
          value
        end

        forms.each do |name, nested_form|
          if nested_form.is_a?(Array)
            data[:each] = {}
            data[:each][:"#{name}_attributes"] = nested_form.first.traverse_hash
          else
            data[:has] = {}
            data[:has][:"#{name}_attributes"] = nested_form.traverse_hash
          end
        end
        data
      end
    end
  end
end
