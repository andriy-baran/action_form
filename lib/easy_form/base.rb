# frozen_string_literal: true

module EasyForm
  # Base class for EasyForm components that provides form building functionality
  # and integrates with Phlex for HTML rendering.
  class Base < ::Phlex::HTML
    include EasyForm::SchemaDSL
    include EasyForm::Rendering

    attr_reader :elements_instances, :forms_instances, :scope, :model, :html_options, :errors

    def initialize(model: nil, scope: self.class.scope, errors: [], **html_options)
      super()
      @namespaced_model = model
      @model = model.is_a?(Array) ? Array(model).last : model
      @scope = scope || param_key
      @html_options = html_options
      @elements_instances = []
      @forms_instances = []
      build_from_model
      @errors = errors
    end

    class << self
      attr_accessor :scope

      def elements
        @elements ||= {}
      end

      def forms
        @forms ||= {}
      end

      # TODO: add support for outputless elements
      def element(name, &block)
        elements[name] = Class.new(EasyForm::Element)
        elements[name].class_eval(&block)
      end

      def has_many(name, &block) # rubocop:disable Naming/PredicatePrefix
        forms[name] = [Class.new(EasyForm::Base)]
        forms[name].last.class_eval(&block)
      end

      def has_one(name, &block) # rubocop:disable Naming/PredicatePrefix
        forms[name] = Class.new(EasyForm::Base)
        forms[name].class_eval(&block)
      end
    end

    def build_from_model # rubocop:disable Metrics/MethodLength
      self.class.forms.each do |name, form_definition|
        value = @model.public_send(name)
        if form_definition.is_a?(Array)
          build_many_forms(name, form_definition.first, value)
        else
          build_one_form(name, form_definition, value)
        end
      end
      self.class.elements.each do |name, element_definition|
        value = @model.public_send(name)
        @elements_instances << element_definition.new(name, value, parent_name: @scope)
      end
    end

    def each_element(&block)
      collection = [elements_instances, forms_instances.map(&:elements_instances)].flatten
      collection.each(&block)
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

    def build_many_forms(name, form_definition, value)
      Array(value).each.with_index do |item, index|
        html_name = @scope ? "#{@scope}[#{name}_attributes][#{index}]" : "[#{name}_attributes][#{index}]"
        @forms_instances << form_definition.new(scope: html_name, model: item)
      end
    end

    def build_one_form(name, form_definition, value)
      html_name = @scope ? "#{@scope}[#{name}_attributes]" : "#{name}_attributes"
      @forms_instances << form_definition.new(scope: html_name, model: value)
    end

    def model_name
      @model.respond_to?(:model_name) ? @model.model_name : ActiveModel::Name.new(@model.class)
    end

    def param_key
      model_name.param_key
    end

    def resource_action
      @model.persisted? ? :update : :create
    end

    def http_method
      @model.persisted? ? "patch" : "post"
    end

    def html_action
      html_options[:action] ||= helpers.polymorphic_path(@namespaced_model)
    end

    def html_method
      html_options[:method] = html_options[:method].to_s.downcase == "get" ? "get" : "post"
    end
  end
end
