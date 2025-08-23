# frozen_string_literal: true

require "ostruct"

module EasyForm
  module Rails
    # RailsForm class for EasyForm that handles Rails-specific form rendering.
    # It integrates with Rails form helpers and provides a Rails-friendly interface
    # for building forms.
    class Base < EasyForm::Base
      include EasyForm::Rails::Rendering

      def self.subform_class
        EasyForm::Rails::Subform
      end

      def initialize(model: nil, scope: self.class.scope, errors: [], **html_options)
        @errors = errors
        @namespaced_model = model
        @object = model.is_a?(Array) ? Array(model).last : model
        @scope = scope || param_key
        super(object: @object, scope: @scope, **html_options)
      end

      class << self
        attr_accessor :scope

        def has_many(name, &block) # rubocop:disable Naming/PredicatePrefix
          super
          elements[name].last.add_primary_key_element
        end

        def has_one(name, &block) # rubocop:disable Naming/PredicatePrefix
          super
          elements[name].add_primary_key_element
        end
      end

      def each_element(&block)
        elements_instances.each(&block)
      end

      def view_template
        render_form do
          render_elements
          render_submit
        end
      end

      def render_in(view_context)
        @_view_context = view_context
        view_context.render html: call.html_safe
      end

      def helpers
        @_view_context
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
        @object.public_send(@object.is_a?(EasyForm::Subform) ? "#{name}_attributes" : name)
      end

      def model_name
        @object.respond_to?(:model_name) ? @object.model_name : ActiveModel::Name.new(@object.class)
      end

      def param_key
        model_name.param_key
      end

      def resource_action
        @object.persisted? ? :update : :create
      end

      def http_method
        @object.persisted? ? "patch" : "post"
      end

      def html_action
        html_options[:action] ||= helpers.polymorphic_path(@namespaced_model)
      end

      def html_method
        html_options[:method] = html_options[:method].to_s.downcase == "get" ? "get" : "post"
      end
    end
  end
end
