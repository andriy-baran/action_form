# frozen_string_literal: true

module EasyForm
  # Base class for EasyForm components that provides form building functionality
  # and integrates with Phlex for HTML rendering.
  class Base < ::Phlex::HTML
    include EasyForm::SchemaDSL
    include EasyForm::ElementsDSL
    include EasyForm::Rendering

    attr_reader :elements_instances, :scope, :object, :html_options, :errors

    def self.subform_class
      EasyForm::Subform
    end

    def initialize(object: nil, scope: nil, **html_options)
      super()
      @object = object
      @scope = scope
      @html_options = html_options
      @elements_instances = []
      build_from_object
    end

    def build_from_object
      self.class.elements.each do |name, element_definition|
        if element_definition < EasyForm::SubformsCollection
          @elements_instances << build_many_subforms(name, element_definition)
          @elements_instances.last.subforms << build_subform_template(name, element_definition.subform_definition)
        elsif element_definition < EasyForm::Subform
          @elements_instances << build_subform(name, element_definition)
        elsif element_definition < EasyForm::Element
          @elements_instances << element_definition.new(name, @params || @object, parent_name: @scope)
        end
      end
    end

    def view_template
      render_form do
        render_elements
        render_submit
      end
    end

    private

    def build_many_subforms(name, collection_definition)
      collection_definition.new(name) do
        Array(subform_value(name)).map.with_index do |item, index|
          build_subform(name, collection_definition.subform_definition, value: item, index: index)
        end
      end
    end

    def subform_html_name(name, index: nil)
      if index
        @scope ? "#{@scope}[#{name}][#{index}]" : "[#{name}][#{index}]"
      else
        @scope ? "#{@scope}[#{name}]" : name
      end
    end

    def subform_value(name)
      @object.public_send(name)
    end

    def build_subform(name, form_definition, value: subform_value(name), index: nil)
      html_name = subform_html_name(name, index: index)
      form_definition.new(name: name, scope: html_name, model: value)
    end

    def build_subform_template(name, form_definition)
      html_name = subform_html_name(name, index: "NEW_RECORD")
      elements_keys = form_definition.elements.keys.push(:persisted?)
      value = Struct.new(*elements_keys).new
      form_definition.new(name: name, scope: html_name, model: value, template: true)
    end
  end
end
