# frozen_string_literal: true

module EasyForm
  module Rails
    # Subform class for EasyForm that handles nested form structures.
    # It allows building forms within forms, supporting has_one and has_many relationships.
    # Includes schema and element DSL functionality for defining form elements.
    class Subform < EasyForm::Subform
      ABSTRACT_PK_ELEMENT = :__primary_key

      class << self
        def add_primary_key_element
          element ABSTRACT_PK_ELEMENT do
            input(type: :hidden, autocomplete: :off)
            output(type: :integer)

            def self.abstract?
              true
            end
          end
        end
      end

      def build_from_object
        super
        return unless @object.persisted?

        primary_key = @object.class.primary_key.to_sym
        return if self.class.elements.key?(primary_key)

        primary_key_element = self.class.elements[ABSTRACT_PK_ELEMENT]
        elements_instances << primary_key_element.new(primary_key, @object, parent_name: @scope)
      end
    end
  end
end
