class FormObject < EasyForm::Base
  def build
    element :birthdate do
      input(type: :text, class: "form-control")
      output(type: :date, presence: true)
    end

    element :biography do
      input(type: :checkbox, label: "Biography")
      output(type: :bool, presence: true)
    end

    has_many :pets do
      element :id do
        input(type: :select, multiple: true, class: "form-control")
        output(type: :integer, presence: true)
        options(PETS.map(&:to_a))
      end
    end

    has_one :car do
      element :maker_id do
        input(type: :radio, class: "form-control")
        output(type: :string, presence: true)
        options(MAKERS.map(&:to_a))
      end
    end
  end

  def view_template # rubocop:disable Metrics/MethodLength
    div(class: "row") do
      form(method: "post", action: "/") do
        div(class: "col-md-6") do
          elements.values_at(:birthdate, :biography).each do |element|
            render_element(element)
          end
        end
        div(class: "col-md-6") do
          forms[:car].elements.each do |name, element|
            render_element(element)
          end
        end
        div(class: "col-md-6") do
          forms[:pets].each do |form|
            form.elements.each do |name, element|
              render_element(element)
            end
          end
        end
      end
    end
  end
end

Pet = Struct.new(:id, :name)
Car = Struct.new(:maker_id)
Maker = Struct.new(:id, :name)

MAKERS = [
  Maker.new(1, "Toyota"),
  Maker.new(2, "Ford"),
  Maker.new(3, "Chevrolet")
].freeze

PETS = [
  Pet.new(1, "Fido"),
  Pet.new(2, "Buddy"),
  Pet.new(3, "Max"),
  Pet.new(4, "Bella"),
  Pet.new(5, "Luna")
].freeze

class Info
  attr_accessor :birthdate, :biography, :pets, :car

  def initialize
    @birthdate = "1990-01-01"
    @biography = false
    @pets = [
      Pet.new(1, "Fido"),
      Pet.new(2, "Buddy")
    ]
    @car = Car.new(1)
  end
end

RSpec.describe "FormObject" do
  it "renders a form with nested elements" do
    form = FormObject.new(name: :info, object: Info.new)
    html = form.call

    expect(html).to eq(
      '<div class="row">' \
        '<form method="post" action="/">' \
          '<div class="col-md-6">' \
            '<label for="info_birthdate">Birthdate</label>' \
            '<input type="text" class="form-control" name="info[birthdate]" id="info_birthdate" value="1990-01-01">' \
            '<label for="info_biography">Biography</label>' \
            '<input name="info[biography]" type="hidden" value="0" autocomplete="off">' \
            '<input type="checkbox" name="info[biography]" id="info_biography" value="1">' \
          "</div>" \
          '<div class="col-md-6">' \
            '<label for="info_car_attributes_maker_id">Maker</label>' \
            '<label for="info_car_attributes_maker_id">Toyota</label>' \
            '<input type="radio" class="form-control" name="info[car_attributes][maker_id]" id="info_car_attributes_maker_id" value="1" checked>' \
            '<label for="info_car_attributes_maker_id">Ford</label>' \
            '<input type="radio" class="form-control" name="info[car_attributes][maker_id]" id="info_car_attributes_maker_id" value="2">' \
            '<label for="info_car_attributes_maker_id">Chevrolet</label>' \
            '<input type="radio" class="form-control" name="info[car_attributes][maker_id]" id="info_car_attributes_maker_id" value="3">' \
          "</div>" \
          '<div class="col-md-6">' \
            '<label for="info_pets_attributes_0_id">Id</label>' \
            '<select multiple class="form-control" name="info[pets_attributes][0][id]" id="info_pets_attributes_0_id">' \
            '<option value="1" selected>Fido</option>' \
            '<option value="2">Buddy</option>' \
            '<option value="3">Max</option>' \
            '<option value="4">Bella</option>' \
            '<option value="5">Luna</option>' \
            "</select>" \
            '<label for="info_pets_attributes_1_id">Id</label>' \
            '<select multiple class="form-control" name="info[pets_attributes][1][id]" id="info_pets_attributes_1_id">' \
            '<option value="1">Fido</option>' \
            '<option value="2" selected>Buddy</option>' \
            '<option value="3">Max</option>' \
            '<option value="4">Bella</option>' \
            '<option value="5">Luna</option>' \
            "</select></div></form></div>"
    )
    schema = form.schema.new(birthdate: "1990-01-01", biography: true, pets_attributes: [{ id: 1 }, { id: 2 }],
                             car_attributes: { maker_id: 1 })
    expect(schema.birthdate).to eq(Date.parse("1990-01-01"))
    expect(schema.biography).to eq(true)
    expect(schema.pets_attributes.map(&:id)).to eq([1, 2])
    expect(schema.car_attributes.maker_id).to eq("1")
  end
end
