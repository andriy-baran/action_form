# frozen_string_literal: true

module ActionForm
  module Rails
    # Subform class for ActionForm that handles nested form structures.
    # It allows building forms within forms, supporting has_one and has_many relationships.
    # Includes schema and element DSL functionality for defining form elements.
    class Subform < ActionForm::Subform
      class << self
        def add_primary_key_element
          return if elements.key?(:id)

          element :id do
            input(type: :hidden, autocomplete: :off)
            output(type: :integer)

            def render?
              object.persisted? || (object.is_a?(EasyParams::Base) && !object.id.nil?)
            end
          end
        end

        def add_delete_element
          element :_destroy do
            input(type: :hidden, autocomplete: :off, value: "0")
            output(type: :bool)

            def render?
              object.persisted? || (object.is_a?(EasyParams::Base) && !object._destroy.nil?)
            end

            def detached?
              true
            end
          end
        end
      end

      def html_class
        object.id.nil? ? "new_#{name}" : super
      end
    end
  end
end
