# frozen_string_literal: true

module EasyForm
  # Subform class for EasyForm that handles nested form structures.
  # It allows building forms within forms, supporting has_one and has_many relationships.
  # Includes schema and element DSL functionality for defining form elements.
  class Subform
    include EasyForm::SchemaDSL
    include EasyForm::ElementsDSL

    attr_reader :elements_instances

    def initialize(scope: nil, model: nil)
      @scope = scope
      @object = model
      @elements_instances = []
      build_from_object
    end

    def build_from_object
      self.class.elements.each do |name, element_definition|
        @elements_instances << element_definition.new(name, @object, parent_name: @scope)
      end
    end
  end
end
