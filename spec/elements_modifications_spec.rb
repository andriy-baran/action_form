class OrderForm < ActionForm::Base
  element :name do
    input(type: :text)
    output(type: :string)
  end

  subform :customer do
    element :name do
      input(type: :text)
      output(type: :string)
    end
  end

  many :items do
    subform do
      element :name do
        input(type: :text)
        output(type: :string)
      end

      element :quantity do
        input(type: :number)
        output(type: :integer)
      end

      element :price do
        input(type: :number)
        output(type: :float)
      end
    end
  end
end

RSpec.describe "OrderForm" do
  it "renders a form with params" do
    secure = true
    OrderForm.name_element do
      output(type: :string, presence: true, if: -> { secure })
    end
    OrderForm.customer_subform default: {} do
      name_element do
        output(type: :string, presence: true, if: -> { secure })
      end
    end
    OrderForm.items_subforms default: [{}] do
      subform do
        name_element do
          output(type: :string, presence: true, if: -> { secure })
        end
        quantity_element do
          output(type: :integer, presence: true, if: -> { secure })
        end
        price_element do
          output(type: :float, presence: true, if: -> { secure })
        end
      end
    end
    params = OrderForm.params_definition.new()

    expect(params).to be_invalid
    expect(params.errors.full_messages).to eq(
      [ "Customer attributes name can't be blank",
        "Items attributes[0] name can't be blank",
        "Items attributes[0] quantity can't be blank",
        "Items attributes[0] price can't be blank",
        "Name can't be blank"] )
    expect(params.customer_attributes.errors.full_messages).to eq(["Name can't be blank"])
    expect(params.items_attributes.first.errors.full_messages).to eq(
      ["Name can't be blank", "Quantity can't be blank", "Price can't be blank"])
  end
end