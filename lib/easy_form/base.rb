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
      instance_exec(&self.class.build_block) if self.class.build_block
    end

    def self.build(&block)
      block ? @build_block = block : @build_block
    end

    def element(name, &block)
      value = @object.public_send(name)
      elements[name] = EasyForm::Element.new(name, value, parent_name: @name)
      elements[name].instance_exec(&block)
      # define_method("#{name}_element") do
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

    private

    def param_key
      @object.respond_to?(:model_name) ? @object.model_name.param_key : ActiveModel::Name.new(@object.class).param_key
    end
  end
end
