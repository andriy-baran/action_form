# frozen_string_literal: true

module ActionForm
  # Base class for ActionForm components that provides form building functionality
  # and integrates with Phlex for HTML rendering.
  class Base < ::Phlex::HTML
    include ActionForm::SchemaDSL
    include ActionForm::ElementsDSL
    include ActionForm::Rendering
    include ActionForm::Composition

    attr_reader :elements_instances, :scope, :object, :html_options, :errors

    class << self
      attr_writer :elements, :scope, :params_definition

      def subform_class
        ActionForm::Subform
      end

      def scope(scope = nil)
        return @scope unless scope

        @scope = scope
      end

      def inherited(subclass)
        super
        subclass.elements = elements.dup
        subclass.scope = scope.dup
        subclass.params_definition = Class.new(params_definition)
        subclass.params_definition.form_class = subclass
      end
    end

    def initialize(object: nil, scope: self.class.scope, params: nil, owner: nil, **html_options)
      super()
      @object = object
      @scope ||= scope
      @params = params
      @html_options = html_options
      @elements_instances = []
      @owner = owner
      build_from_object
    end

    def build_from_object
      self.class.elements.each do |name, element_definition|
        if element_definition < ActionForm::SubformsCollection
          @elements_instances << build_many_subforms(name, element_definition)
          @elements_instances.last << build_subform_template(name, element_definition.subform_definition)
        elsif element_definition < ActionForm::Subform
          @elements_instances << build_subform(name, element_definition)
        elsif element_definition < ActionForm::Element
          @elements_instances << element_definition.new(name, @params || @object, parent_name: @scope, owner: self)
        end
      end
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

    def build_many_subforms(name, collection_definition)
      collection = collection_definition.new(name)
      collection.owner = self
      Array(subform_value(name)).each.with_index do |item, index|
        collection << build_subform(name, collection_definition.subform_definition, value: item, index: index)
      end
      collection
    end

    def subform_html_name(name, index: nil)
      if index
        @scope ? "#{@scope}[#{name}][#{index}]" : "[#{name}][#{index}]"
      else
        @scope ? "#{@scope}[#{name}]" : name
      end
    end

    def subform_value(name)
      @object&.public_send(name) || @params&.public_send(:"#{name}_attributes")
    end

    def build_subform(name, form_definition, value: subform_value(name), index: nil)
      html_name = subform_html_name(name, index: index)
      form_definition.new(name: name, scope: html_name, model: value, index: index,
                          owner: self).tap do |subform|
        subform.helpers = helpers
      end
    end

    def build_subform_template(name, form_definition)
      html_name = subform_html_name(name, index: "NEW_RECORD")
      elements_keys = form_definition.elements.keys.push(:persisted?)
      values = form_definition.elements.values.map(&:default)
      value = Struct.new(*elements_keys).new(*values)
      form_definition.new(name: name, scope: html_name, model: value, template: true,
                          owner: self).tap do |subform|
        subform.helpers = helpers
      end
    end
  end
end
