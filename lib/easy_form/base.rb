# frozen_string_literal: true

module EasyForm
  # Base class for EasyForm components that provides form building functionality
  # and integrates with Phlex for HTML rendering.
  class Base < ::Phlex::HTML
    include EasyForm::SchemaDSL
    include EasyForm::Rendering

    attr_reader :elements, :scope, :forms, :model, :html_options

    def initialize(model: nil, scope: nil, **html_options)
      super()
      @model = model
      @scope = scope || param_key
      @html_options = html_options
      @elements = {}
      @forms = {}
      build
    end

    def build; end

    # TODO: add support for outputless elements
    def element(name, &block)
      value = @model.public_send(name)
      elements[name] = EasyForm::Element.new(name, value, parent_name: @scope)
      elements[name].instance_exec(&block)
    end

    def has_many(name, &block) # rubocop:disable Naming/PredicatePrefix
      value = @model.public_send(name)
      forms[name] ||= []
      Array(value).each.with_index do |item, index|
        html_name = @scope ? "#{@scope}[#{name}_attributes][#{index}]" : "[#{name}_attributes][#{index}]"
        form = EasyForm::Base.new(scope: html_name, model: item)
        form.instance_exec(&block)
        forms[name] << form
      end
    end

    def has_one(name, &block) # rubocop:disable Naming/PredicatePrefix
      value = @model.public_send(name)
      html_name = @scope ? "#{@scope}[#{name}_attributes]" : "#{name}_attributes"
      forms[name] = EasyForm::Base.new(scope: html_name, model: value)
      forms[name].instance_exec(&block)
    end

    def each_element(&block)
      collection = [elements.values, forms.values.flatten.map(&:elements).map(&:values)].flatten
      collection.each(&block)
    end

    private

    def model_name
      @model.respond_to?(:model_name) ? @model.model_name : ActiveModel::Name.new(@model.class)
    end

    def param_key
      model_name.param_key
    end
  end
end
