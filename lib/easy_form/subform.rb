# frozen_string_literal: true

module EasyForm
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
        value = @model.public_send(name)
        @elements_instances << element_definition.new(name, value, parent_name: @scope)
      end
    end
  end
end
