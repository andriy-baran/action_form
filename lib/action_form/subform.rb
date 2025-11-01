# frozen_string_literal: true

module ActionForm
  # Subform class for ActionForm that handles nested form structures.
  # It allows building forms within forms, supporting has_one and has_many relationships.
  # Includes schema and element DSL functionality for defining form elements.
  class Subform < ::Phlex::HTML
    include ActionForm::Rendering
    include ActionForm::SchemaDSL
    include ActionForm::ElementsDSL
    include ActionForm::Composition

    class << self
      attr_accessor :default
      attr_writer :elements

      def inherited(subclass)
        super
        subclass.elements = elements.dup
        subclass.default = default.dup
      end
    end

    attr_reader :elements_instances, :tags, :name, :object
    attr_accessor :helpers

    def initialize(name:, scope: nil, model: nil, params: nil, owner: nil, **tags) # rubocop:disable Metrics/ParameterLists
      super()
      @name = name
      @scope = scope
      @object = model
      @params = params
      @elements_instances = []
      @tags = tags
      @owner = owner
      build_from_object
    end

    def build_from_object
      self.class.elements.each do |element_name, element_definition|
        @elements_instances << element_definition.new(element_name, @params || @object, parent_name: @scope)
        @elements_instances.last.tags.merge!(subform: @name)
        @elements_instances.last.owner = self
      end
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

    def view_template
      render_elements
    end
  end
end
