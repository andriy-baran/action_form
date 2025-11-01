class ProductForm < ActionForm::Base
  element :name do
    input(type: :text)
    output(type: :string)

    def render?
      name_render?
    end
  end

  many :variants, default: [{}] do
    subform do
      element :name do
        input(type: :text)
        output(type: :string)

        def render?
          variants_name_render?
        end
      end

      element :price do
        input(type: :number)
        output(type: :float)

        def render?
          variants_price_render?
        end
      end

      def render?
        variants_subform_render?
      end
    end
  end

  subform :manufacturer, default: {} do
    element :name do
      input(type: :text)
      output(type: :string)

      def render?
        manufacturer_name_render?
      end
    end
  end
end

class HostObject
  def name_render?
    true
  end

  def variants_subform_render?
    true
  end

  def variants_name_render?
    true
  end

  def variants_price_render?
    true
  end

  def manufacturer_name_render?
    true
  end
end

class Product < Struct.new(:name, :variants, :manufacturer)
  def persisted?
    false
  end
end

class Variant < Struct.new(:name, :price)
  def persisted?
    false
  end
end

class Manufacturer < Struct.new(:name)
  def persisted?
    false
  end
end

RSpec.describe "ProductForm" do
  it "renders a form with params" do
    owner = HostObject.new
    variants = [Variant.new(name: "Variant 1", price: 10.0)]
    manufacturer = Manufacturer.new(name: "Manufacturer 1")
    product = Product.new(name: "Product 1", variants: variants, manufacturer: manufacturer)
    product_form = ProductForm.new(object: product, owner: owner)
    render_result = product_form.elements_instances.map(&:render?)
    expect(render_result).to eq([true, true, true])
    render_result = product_form.elements_instances[1].subforms.map(&:render?)
    expect(render_result).to eq([true, true])
    render_result = product_form.elements_instances[1].subforms[0].elements_instances.map(&:render?)
    expect(render_result).to eq([true, true])
    render_result = product_form.elements_instances[2].elements_instances.map(&:render?)
    expect(render_result).to eq([true])

    owner_result = product_form.elements_instances.map(&:owner)
    expect(owner_result).to eq([product_form, product_form, product_form])
    owner_result = product_form.elements_instances[1].subforms.map(&:owner)
    expect(owner_result).to eq([product_form, product_form])
    owner_result = product_form.elements_instances[1].subforms[0].elements_instances.map(&:owner)
    subforms_collection = product_form.elements_instances[1].subforms[0]
    expect(owner_result).to eq([subforms_collection, subforms_collection])
    owner_result = product_form.elements_instances[2].elements_instances.map(&:owner)
    subform = product_form.elements_instances[2]
    expect(owner_result).to eq([subform])
  end
end