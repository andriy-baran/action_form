# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Element Tags" do
  # Test model for validation errors
  class TestModel
    attr_accessor :name, :email, :age, :category

    def initialize(attrs = {})
      @name = attrs[:name]
      @email = attrs[:email]
      @age = attrs[:age]
      @category = attrs[:category]
    end

    def errors
      @errors ||= TestErrors.new(self)
    end

    class TestErrors
      def initialize(model)
        @model = model
        @messages = {}
      end

      def messages_for(attribute)
        @messages[attribute] || []
      end

      def add(attribute, message)
        @messages[attribute] ||= []
        @messages[attribute] << message
      end

      def any?
        @messages.any?
      end
    end
  end

  describe "Automatic Tags" do
    it "adds input tag when input type is specified" do
      form_class = Class.new(ActionForm::Base) do
        element :name do
          input(type: :text)
          output(type: :string)
        end
      end

      form = form_class.new
      element = form.elements_instances.first

      expect(element.tags[:input]).to eq(:text)
    end

    it "adds output tag when output type is specified" do
      form_class = Class.new(ActionForm::Base) do
        element :email do
          input(type: :email)
          output(type: :string)
        end
      end

      form = form_class.new
      element = form.elements_instances.first

      expect(element.tags[:output]).to eq(:string)
    end

    it "adds options tag when options are specified" do
      form_class = Class.new(ActionForm::Base) do
        element :category do
          input(type: :select)
          output(type: :string)
          options([["Admin", "admin"], ["User", "user"]])
        end
      end

      form = form_class.new
      element = form.elements_instances.first

      expect(element.tags[:options]).to eq(true)
    end

    it "allows multiple automatic tags to coexist" do
      form_class = Class.new(ActionForm::Base) do
        element :status do
          input(type: :select)
          output(type: :string)
          options([["Active", "active"], ["Inactive", "inactive"]])
        end
      end

      form = form_class.new
      element = form.elements_instances.first

      expect(element.tags[:input]).to eq(:select)
      expect(element.tags[:output]).to eq(:string)
      expect(element.tags[:options]).to eq(true)
    end

    it "preserves input tag for different input types" do
      form_class = Class.new(ActionForm::Base) do
        element :password do
          input(type: :password)
          output(type: :string)
        end

        element :age do
          input(type: :number)
          output(type: :integer)
        end

        element :bio do
          input(type: :textarea)
          output(type: :string)
        end
      end

      form = form_class.new
      password_element = form.elements_instances.find { |e| e.name == :password }
      age_element = form.elements_instances.find { |e| e.name == :age }
      bio_element = form.elements_instances.find { |e| e.name == :bio }

      expect(password_element.tags[:input]).to eq(:password)
      expect(age_element.tags[:input]).to eq(:number)
      expect(bio_element.tags[:input]).to eq(:textarea)
    end

    it "preserves output tag for different output types" do
      form_class = Class.new(ActionForm::Base) do
        element :name do
          input(type: :text)
          output(type: :string)
        end

        element :age do
          input(type: :number)
          output(type: :integer)
        end

        element :price do
          input(type: :number)
          output(type: :float)
        end

        element :active do
          input(type: :checkbox)
          output(type: :bool)
        end
      end

      form = form_class.new
      name_element = form.elements_instances.find { |e| e.name == :name }
      age_element = form.elements_instances.find { |e| e.name == :age }
      price_element = form.elements_instances.find { |e| e.name == :price }
      active_element = form.elements_instances.find { |e| e.name == :active }

      expect(name_element.tags[:output]).to eq(:string)
      expect(age_element.tags[:output]).to eq(:integer)
      expect(price_element.tags[:output]).to eq(:float)
      expect(active_element.tags[:output]).to eq(:bool)
    end
  end

  describe "Custom Tags" do
    it "adds custom tags using tags method" do
      form_class = Class.new(ActionForm::Base) do
        element :priority do
          input(type: :text)
          output(type: :string)
          tags priority: "high"
        end
      end

      form = form_class.new
      element = form.elements_instances.first

      expect(element.tags[:priority]).to eq("high")
    end

    it "adds multiple custom tags" do
      form_class = Class.new(ActionForm::Base) do
        element :field do
          input(type: :text)
          output(type: :string)
          tags row: "3", column: "4", background: "gray"
        end
      end

      form = form_class.new
      element = form.elements_instances.first

      expect(element.tags[:row]).to eq("3")
      expect(element.tags[:column]).to eq("4")
      expect(element.tags[:background]).to eq("gray")
    end

    it "allows custom tags to be accessed via element.tags" do
      form_class = Class.new(ActionForm::Base) do
        element :section do
          input(type: :text)
          output(type: :string)
          tags section: "contact", field_type: "email"
        end
      end

      form = form_class.new
      element = form.elements_instances.first

      expect(element.tags[:section]).to eq("contact")
      expect(element.tags[:field_type]).to eq("email")
    end

    it "persists custom tags on element instances" do
      form_class = Class.new(ActionForm::Base) do
        element :custom_field do
          input(type: :text)
          output(type: :string)
          tags custom_validation: true, required: true
        end
      end

      form = form_class.new
      element = form.elements_instances.first

      expect(element.tags[:custom_validation]).to eq(true)
      expect(element.tags[:required]).to eq(true)
    end

    it "allows custom tags with different value types" do
      form_class = Class.new(ActionForm::Base) do
        element :mixed_tags do
          input(type: :text)
          output(type: :string)
          tags string_tag: "value",
               symbol_tag: :symbol_value,
               boolean_tag: true,
               integer_tag: 42,
               nil_tag: nil
        end
      end

      form = form_class.new
      element = form.elements_instances.first

      expect(element.tags[:string_tag]).to eq("value")
      expect(element.tags[:symbol_tag]).to eq(:symbol_value)
      expect(element.tags[:boolean_tag]).to eq(true)
      expect(element.tags[:integer_tag]).to eq(42)
      expect(element.tags[:nil_tag]).to be_nil
    end
  end

  describe "Errors Tag" do
    it "adds errors: true tag when element has validation errors" do
      model = TestModel.new
      model.errors.add(:name, "can't be blank")

      form_class = Class.new(ActionForm::Base) do
        element :name do
          input(type: :text)
          output(type: :string)
        end
      end

      form = form_class.new(object: model)
      element = form.elements_instances.first

      expect(element.tags[:errors]).to eq(true)
    end

    it "adds errors: false tag when element has no errors" do
      model = TestModel.new(name: "John")

      form_class = Class.new(ActionForm::Base) do
        element :name do
          input(type: :text)
          output(type: :string)
        end
      end

      form = form_class.new(object: model)
      element = form.elements_instances.first

      expect(element.tags[:errors]).to eq(false)
    end

    it "dynamically updates errors tag based on validation state" do
      model = TestModel.new
      form_class = Class.new(ActionForm::Base) do
        element :email do
          input(type: :email)
          output(type: :string)
        end
      end

      form = form_class.new(object: model)
      element = form.elements_instances.first

      # Initially no errors
      expect(element.tags[:errors]).to eq(false)

      # Add error
      model.errors.add(:email, "is invalid")
      element = form_class.new(object: model).elements_instances.first

      expect(element.tags[:errors]).to eq(true)
    end

    it "handles errors tag for multiple elements independently" do
      model = TestModel.new
      model.errors.add(:name, "can't be blank")
      # email has no errors

      form_class = Class.new(ActionForm::Base) do
        element :name do
          input(type: :text)
          output(type: :string)
        end

        element :email do
          input(type: :email)
          output(type: :string)
        end
      end

      form = form_class.new(object: model)
      name_element = form.elements_instances.find { |e| e.name == :name }
      email_element = form.elements_instances.find { |e| e.name == :email }

      expect(name_element.tags[:errors]).to eq(true)
      expect(email_element.tags[:errors]).to eq(false)
    end
  end

  describe "Tag Merging and Access" do
    it "copies class-level tags to instance-level tags" do
      form_class = Class.new(ActionForm::Base) do
        element :field do
          input(type: :text)
          output(type: :string)
          tags custom: "value"
        end
      end

      form = form_class.new
      element = form.elements_instances.first

      # Tags should be available on instance
      expect(element.tags[:input]).to eq(:text)
      expect(element.tags[:output]).to eq(:string)
      expect(element.tags[:custom]).to eq("value")
    end

    it "tags from class definition are available on instances" do
      form_class = Class.new(ActionForm::Base) do
        element :tagged_field do
          input(type: :select)
          output(type: :string)
          options([["Option 1", "1"]])
          tags section: "main", priority: "high"
        end
      end

      form = form_class.new
      element = form.elements_instances.first

      expect(element.tags[:input]).to eq(:select)
      expect(element.tags[:output]).to eq(:string)
      expect(element.tags[:options]).to eq(true)
      expect(element.tags[:section]).to eq("main")
      expect(element.tags[:priority]).to eq("high")
    end

    it "allows automatic and custom tags to be combined" do
      form_class = Class.new(ActionForm::Base) do
        element :combined do
          input(type: :email)
          output(type: :string)
          options([["Admin", "admin"]])
          tags row: "1", column: "2"
        end
      end

      form = form_class.new
      element = form.elements_instances.first

      # Automatic tags
      expect(element.tags[:input]).to eq(:email)
      expect(element.tags[:output]).to eq(:string)
      expect(element.tags[:options]).to eq(true)

      # Custom tags
      expect(element.tags[:row]).to eq("1")
      expect(element.tags[:column]).to eq("2")
    end

    it "tags are independent for each element instance" do
      form_class = Class.new(ActionForm::Base) do
        element :field1 do
          input(type: :text)
          output(type: :string)
          tags section: "one"
        end

        element :field2 do
          input(type: :text)
          output(type: :string)
          tags section: "two"
        end
      end

      form = form_class.new
      field1 = form.elements_instances.find { |e| e.name == :field1 }
      field2 = form.elements_instances.find { |e| e.name == :field2 }

      expect(field1.tags[:section]).to eq("one")
      expect(field2.tags[:section]).to eq("two")
      expect(field1.tags[:section]).not_to eq(field2.tags[:section])
    end

    it "allows modifying custom tags on instance" do
      form_class = Class.new(ActionForm::Base) do
        element :overwrite_test do
          input(type: :text)
          output(type: :string)
          tags priority: "low"
        end
      end

      form = form_class.new
      element = form.elements_instances.first

      expect(element.tags[:priority]).to eq("low")

      # Custom tags can be modified on instance (though this might not be typical usage)
      element.tags[:priority] = "high"
      expect(element.tags[:priority]).to eq("high")
    end
  end

  describe "Edge Cases" do
    it "handles elements with no tags gracefully" do
      form_class = Class.new(ActionForm::Base) do
        element :minimal do
          input(type: :hidden)
          output(type: :string)
        end
      end

      form = form_class.new
      element = form.elements_instances.first

      # Should have at least automatic tags
      expect(element.tags).to be_a(Hash)
      expect(element.tags[:input]).to eq(:hidden)
      expect(element.tags[:output]).to eq(:string)
      expect(element.tags[:errors]).to eq(false)
    end

    it "handles elements with only automatic tags" do
      form_class = Class.new(ActionForm::Base) do
        element :auto_only do
          input(type: :text)
          output(type: :string)
        end
      end

      form = form_class.new
      element = form.elements_instances.first

      expect(element.tags[:input]).to eq(:text)
      expect(element.tags[:output]).to eq(:string)
      expect(element.tags[:errors]).to eq(false)
      expect(element.tags[:options]).to be_nil
    end

    it "handles elements with only custom tags" do
      form_class = Class.new(ActionForm::Base) do
        element :custom_only do
          input(type: :text)
          output(type: :string)
          tags custom: "only"
        end
      end

      form = form_class.new
      element = form.elements_instances.first

      # Should have both automatic and custom tags
      expect(element.tags[:input]).to eq(:text)
      expect(element.tags[:output]).to eq(:string)
      expect(element.tags[:custom]).to eq("only")
    end

    it "handles tag value types correctly" do
      form_class = Class.new(ActionForm::Base) do
        element :type_test do
          input(type: :text)
          output(type: :string)
          tags string_val: "test",
               symbol_val: :test,
               bool_val: false,
               int_val: 123,
               float_val: 45.67,
               array_val: [1, 2, 3],
               hash_val: { key: "value" }
        end
      end

      form = form_class.new
      element = form.elements_instances.first

      expect(element.tags[:string_val]).to eq("test")
      expect(element.tags[:symbol_val]).to eq(:test)
      expect(element.tags[:bool_val]).to eq(false)
      expect(element.tags[:int_val]).to eq(123)
      expect(element.tags[:float_val]).to eq(45.67)
      expect(element.tags[:array_val]).to eq([1, 2, 3])
      expect(element.tags[:hash_val]).to eq({ key: "value" })
    end

    it "handles empty tags hash" do
      form_class = Class.new(ActionForm::Base) do
        element :empty_tags do
          input(type: :text)
          output(type: :string)
        end
      end

      form = form_class.new
      element = form.elements_instances.first

      # Should still have automatic tags
      expect(element.tags).not_to be_empty
      expect(element.tags[:input]).to eq(:text)
      expect(element.tags[:output]).to eq(:string)
    end

    it "handles tags added via element modification method" do
      form_class = Class.new(ActionForm::Base) do
        element :multi_tags do
          input(type: :text)
          output(type: :string)
        end
      end

      # Modify tags using the element method
      form_class.multi_tags_element do
        tags priority: "high", section: "main"
      end

      form = form_class.new
      element = form.elements_instances.first

      # Tags should be added
      expect(element.tags[:priority]).to eq("high")
      expect(element.tags[:section]).to eq("main")
    end

    it "prevents custom tags from overriding automatic input tag" do
      form_class = Class.new(ActionForm::Base) do
        element :protected_input do
          input(type: :text)
          output(type: :string)
          tags input: :email  # Attempt to override
        end
      end

      form = form_class.new
      element = form.elements_instances.first

      # Automatic tag should not be overridden
      expect(element.tags[:input]).to eq(:text)
      expect(element.tags[:input]).not_to eq(:email)
    end

    it "prevents custom tags from overriding automatic output tag" do
      form_class = Class.new(ActionForm::Base) do
        element :protected_output do
          input(type: :text)
          output(type: :string)
          tags output: :integer  # Attempt to override
        end
      end

      form = form_class.new
      element = form.elements_instances.first

      # Automatic tag should not be overridden
      expect(element.tags[:output]).to eq(:string)
      expect(element.tags[:output]).not_to eq(:integer)
    end

    it "prevents custom tags from overriding automatic options tag" do
      form_class = Class.new(ActionForm::Base) do
        element :protected_options do
          input(type: :select)
          output(type: :string)
          options([["Option 1", "1"]])
          tags options: false  # Attempt to override
        end
      end

      form = form_class.new
      element = form.elements_instances.first

      # Automatic tag should not be overridden
      expect(element.tags[:options]).to eq(true)
      expect(element.tags[:options]).not_to eq(false)
    end

    it "prevents custom tags from overriding errors tag" do
      model = TestModel.new
      model.errors.add(:name, "can't be blank")

      form_class = Class.new(ActionForm::Base) do
        element :name do
          input(type: :text)
          output(type: :string)
          tags errors: false  # Attempt to override
        end
      end

      form = form_class.new(object: model)
      element = form.elements_instances.first

      # Automatic errors tag should not be overridden
      expect(element.tags[:errors]).to eq(true)
      expect(element.tags[:errors]).not_to eq(false)
    end

    it "allows custom tags alongside protected automatic tags" do
      form_class = Class.new(ActionForm::Base) do
        element :mixed_protected do
          input(type: :text)
          output(type: :string)
          options([["Option", "opt"]])
          tags custom: "value", input: :email, output: :integer  # Attempt to override + custom
        end
      end

      form = form_class.new
      element = form.elements_instances.first

      # Automatic tags should be preserved
      expect(element.tags[:input]).to eq(:text)
      expect(element.tags[:output]).to eq(:string)
      expect(element.tags[:options]).to eq(true)

      # Custom tag should still be added
      expect(element.tags[:custom]).to eq("value")
    end
  end
end

