# frozen_string_literal: true

module EasyForm
  # Base class for EasyForm components that provides form building functionality
  # and integrates with Phlex for HTML rendering.
  class Base < ::Phlex::HTML
    include EasyForm::SchemaDSL
    include EasyForm::ElementsDSL
    include EasyForm::Rendering

    attr_reader :elements_instances, :scope, :object, :html_options, :errors

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
        if element_definition.is_a?(Array)
          build_many_subforms(name, element_definition.first)
        elsif element_definition < EasyForm::Subform
          build_subform(name, element_definition)
        elsif element_definition < EasyForm::Element
          @elements_instances << element_definition.new(name, @object, parent_name: @scope)
        end
      end
    end

    def each_element(&block)
      elements_instances.select(&:render?).each(&block)
    end

    def view_template
      render_form do
        render_elements
        render_submit
      end
    end

    private

    def build_many_subforms(name, form_definition)
      Array(subform_value(name)).each.with_index do |item, index|
        build_subform(name, form_definition, value: item, index: index)
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
      form_instance = form_definition.new(scope: html_name, model: value)
      @elements_instances.concat(form_instance.elements_instances)
    end
  end
end
