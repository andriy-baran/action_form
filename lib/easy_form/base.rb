module EasyForm
  class Base < ::Phlex::HTML
    include EasyForm::SchemaDSL

    def schema
      @schema ||= Class.new(EasyParams::Base).tap do |schema|
        schema.class_eval(self.class.hash_to_dsl_string(traverse_hash))
      end
    end

    class << self
      attr_reader :schema, :build_block
    end
    class << self
      def elements
        @elements ||= {}
      end

      def element(name, &block)
        elements[name] = EasyForm::Element.new(name, nil)
        elements[name].instance_exec(&block)
      end
    end

    attr_reader :elements, :name, :forms

    def initialize(object: nil, name: nil, **options)
      @object = object
      @name = name || param_key
      @options = options
      @elements = {}
      @forms = {}
      build
    end

    def build; end

    # TODO: add support for outputless elements
    def element(name, &block)
      value = @object.public_send(name)
      elements[name] = EasyForm::Element.new(name, value, parent_name: @name)
      elements[name].instance_exec(&block)
      # define_singleton_method("#{name}_element") do
      #   elements[name]
      # end
    end

    def has_many(name, &block)
      value = @object.public_send(name)
      forms[name] ||= []
      Array(value).each.with_index do |item, index|
        html_name = @name ? "#{@name}[#{name}_attributes][#{index}]" : "[#{name}_attributes][#{index}]"
        form = EasyForm::Base.new(name: html_name, object: item)
        form.instance_exec(&block)
        forms[name] << form
      end
    end

    def has_one(name, &block)
      value = @object.public_send(name)
      html_name = @name ? "#{@name}[#{name}_attributes]" : "#{name}_attributes"
      forms[name] = EasyForm::Base.new(name: html_name, object: value)
      forms[name].instance_exec(&block)
    end

    def each_element(&block)
      collection = [elements.values, forms.values.flatten.map(&:elements).map(&:values)].flatten
      collection.each(&block)
    end

    def render_elements
      each_element(&method(:render_element))
    end

    def render_element(element)
      label(for: element.html_id) { element.label } if element.label
      if %i[checkbox radio select textarea].include?(element.input_options[:type].to_sym)
        public_send("render_#{element.input_options[:type]}", element)
      else
        render_input(element)
      end
    end

    def render_input(element)
      input(**element.html_attributes)
    end

    def render_checkbox(element)
      input(name: element.html_name, type: "hidden", value: "0", autocomplete: "off")
      input(**element.html_attributes.merge(type: "checkbox", value: "1"))
    end

    def render_radio(element)
      element.select_options.each do |value, label|
        label(for: element.html_id) { label }
        input(**element.html_attributes.merge(type: "radio", value: value, checked: value == element.value))
      end
    end

    def render_select(element)
      select(**element.html_attributes) do
        element.select_options.each do |value, label|
          option(value: value, selected: value == element.value) { label }
        end
      end
    end

    def render_textarea(element)
      textarea(**element.html_attributes) { element.value }
    end

    private

    def param_key
      @object.respond_to?(:model_name) ? @object.model_name.param_key : ActiveModel::Name.new(@object.class).param_key
    end
  end
end
