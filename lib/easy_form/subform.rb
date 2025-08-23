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
      @model = model
      @elements_instances = []
      build_from_model
    end

    def build_from_model
      self.class.elements.each do |name, element_definition|
        @elements_instances << element_definition.new(name, @model, parent_name: @scope)
      end
    end

    private

    def build_primary_key_element
      return unless @model.class.respond_to?(:primary_key)

      self.class.element @model.class.primary_key.to_sym do
        input(type: :hidden, autocomplete: :off)
        output(type: :integer)

        def render?
          object.persisted?
        end
      end
    end
  end
end
