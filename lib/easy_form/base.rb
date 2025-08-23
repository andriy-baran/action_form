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
        value = @object.public_send(@object.is_a?(EasyForm::Subform) ? "#{name}_attributes" : name)
        if element_definition.is_a?(Array)
          build_many_forms(name, element_definition.first, value)
        elsif element_definition < EasyForm::Subform
          build_one_form(name, element_definition, value)
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

    def build_many_forms(name, form_definition, value)
      Array(value).each.with_index do |item, index|
        html_name = @scope ? "#{@scope}[#{name}_attributes][#{index}]" : "[#{name}_attributes][#{index}]"
        build_form(html_name, form_definition, item)
      end
    end

    def build_one_form(name, form_definition, value)
      html_name = @scope ? "#{@scope}[#{name}_attributes]" : "#{name}_attributes"
      build_form(html_name, form_definition, value)
    end

    def build_form(html_name, form_definition, value)
      form_instance = form_definition.new(scope: html_name, model: value)
      @elements_instances.concat(form_instance.elements_instances)
    end
  end
end
