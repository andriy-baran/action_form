module EasyForm
  class Base < ::Phlex::HTML
    def schema
      @schema ||= Class.new(EasyParams::Base).tap do |schema|
        elements.each do |name, element|
          options = element.output_options.dup
          method_name = options.delete(:type)
          schema.public_send(method_name, name, **options)
        end
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
      collection = [elements, forms.values.flatten.map(&:elements)].flatten
      collection.each(&block)
    end

    def render_element(element)
      label(for: element.html_id) { element.label } if element.label
      case element.input_options[:type].to_sym
      when :checkbox
        checkbox_tag(element)
      when :radio
        radio_tag(element)
      when :select
        select_tag(element)
      when :textarea
        textarea_tag(element)
      else
        input_tag(element)
      end
    end

    def input_tag(element)
      input(**element.html_attributes)
    end

    def checkbox_tag(element)
      input(name: element.html_name, type: "hidden", value: "0", autocomplete: "off")
      input(**element.html_attributes.merge(type: "checkbox", value: "1"))
    end

    def radio_tag(element)
      element.select_options.each do |value, label|
        label(for: element.html_id) { label }
        input(**element.html_attributes.merge(type: "radio", value: value, checked: value == element.value))
      end
    end

    def select_tag(element)
      select(**element.html_attributes) do
        element.select_options.each do |value, label|
          option(value: value, selected: value == element.value) { label }
        end
      end
    end

    def textarea_tag(element)
      textarea(**element.html_attributes) { element.value }
    end

    private

    def param_key
      @object.respond_to?(:model_name) ? @object.model_name.param_key : ActiveModel::Name.new(@object.class).param_key
    end
  end
end
