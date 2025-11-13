# frozen_string_literal: true

require "ostruct"

module ActionForm
  module Rails
    # RailsForm class for ActionForm that handles Rails-specific form rendering.
    # It integrates with Rails form helpers and provides a Rails-friendly interface
    # for building forms.
    class Base < ActionForm::Base
      include ActionForm::Rails::Rendering

      def self.subform_class
        ActionForm::Rails::Subform
      end

      attr_reader :namespaced_model

      def initialize(model: nil, scope: self.class.scope, params: nil, **html_options)
        @namespaced_model = model
        @object = model.is_a?(Array) ? Array(model).last : model
        @scope = scope.nil? && @object.nil? ? nil : (scope || param_key)
        super(object: @object, scope: @scope, params: params, **html_options)
      end

      class << self
        def resource_model(model = nil)
          return @resource_model unless model

          @resource_model = model
          @scope = model.model_name.param_key.to_sym
        end

        def many(name, default: nil, &block)
          super
          elements[name].subform_definition.add_primary_key_element
          elements[name].subform_definition.add_delete_element
        end

        def subform(name, default: nil, &block)
          super
          elements[name].add_primary_key_element
        end
      end

      def view_template
        render_form do
          render_elements
          render_submit
        end
      end

      private

      def subform_html_name(name, index: nil)
        if index
          @scope ? "#{@scope}[#{name}_attributes][#{index}]" : "[#{name}_attributes][#{index}]"
        else
          @scope ? "#{@scope}[#{name}_attributes]" : "#{name}_attributes"
        end
      end

      def subform_value(name)
        if @params
          @params.send("#{name}_attributes")
        else
          @object.public_send(name)
        end
      end

      def model_name
        @object&.model_name
      end

      def param_key
        model_name.param_key.to_sym
      end

      def resource_action
        return :search if @object.nil?

        @object.persisted? ? :update : :create
      end

      def http_method
        return html_options[:method].to_s.downcase if @object.nil?

        @object.persisted? ? "patch" : "post"
      end

      def html_action
        html_options[:action] ||= helpers.polymorphic_path(@namespaced_model)
      end

      def html_method
        html_options[:method].to_s.downcase == "get" ? "get" : "post"
      end
    end
  end
end
