class FormObject < EasyForm::Base
  build do
    element :birthdate do
      input(type: :text, class: "form-control")
      output(type: :date, presence: true)
    end

    element :biography do
      input(type: :checkbox)
      output(type: :bool, presence: true)
    end

    has_many :pets do
      element :name do
        input(type: :text, class: "form-control")
        output(type: :string, presence: true)
      end
    end

    has_one :car do
      element :make do
        input(type: :text, class: "form-control")
        output(type: :string, presence: true)
      end
    end
  end

  def view_template
    div(class: "row") do
      div(class: "col-md-6") do
        elements.values_at(:birthdate, :biography).each do |element|
          label(for: element.html_id) { element.name }
          input(**element.html_attributes)
        end
      end
      div(class: "col-md-6") do
        forms[:car].elements.each do |name, element|
          label(for: element.html_id) { name }
          input(**element.html_attributes)
        end
      end
      div(class: "col-md-6") do
        forms[:pets].each do |form|
          form.elements.each do |name, element|
            label(for: element.html_id) { name }
            input(**element.html_attributes)
          end
        end
      end
    end
  end
end

Pet = Struct.new(:name)
Car = Struct.new(:make)

class Info
  attr_accessor :birthdate, :biography, :pets, :car

  def initialize
    @birthdate = "1990-01-01"
    @biography = true
    @pets = [
      Pet.new("Fido"),
      Pet.new("Buddy")
    ]
    @car = Car.new("Toyota")
  end
end

RSpec.describe "FormObject" do
  it "renders a form with a checkbox" do
    form = FormObject.new(name: :info, object: Info.new)
    # form.build
    html = form.call
    binding.pry
    expect(html).to eq(
      '<div class="row"><div class="col-md-6"><label for="birthdate">birthdate</label><input type="text" class="form-control" name="birthdate" id="birthdate"><label for="biography">biography</label><input type="checkbox" name="biography" id="biography"></div></div>'
    )
    schema = form.schema.new(birthdate: "1990-01-01", biography: true)
    expect(schema.birthdate).to eq(Date.parse("1990-01-01"))
    expect(schema.biography).to eq(true)
  end
end
