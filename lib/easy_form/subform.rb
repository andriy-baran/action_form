# frozen_string_literal: true

module EasyForm
  # Subform class for EasyForm that handles nested form structures.
  # It allows building forms within forms, supporting has_one and has_many relationships.
  # Includes schema and element DSL functionality for defining form elements.
  class Subform
    include EasyForm::SchemaDSL
    include EasyForm::ElementsDSL

    attr_reader :elements_instances, :tags, :name, :object

    def initialize(name:, scope: nil, model: nil, params: nil, **tags)
      @name = name
      @scope = scope
      @object = model
      @params = params
      @elements_instances = []
      @tags = tags
      build_from_object
    end

    def build_from_object
      self.class.elements.each do |element_name, element_definition|
        @elements_instances << element_definition.new(element_name, @params || @object, parent_name: @scope)
        @elements_instances.last.tags.merge!(subform: @name)
      end
    end

    def each_element(&block)
      elements_instances.each(&block)
    end

    def render?
      true
    end

    def template_html_id
      "#{name}_template"
    end

    def html_id
      "#{name}_#{tags[:index]}"
    end

    def html_class
      "#{name}_subform"
    end
  end
end
