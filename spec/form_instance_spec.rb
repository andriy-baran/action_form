# rubocop:disable Layout/LineLength
# rubocop:disable Metrics/BlockLength
# frozen_string_literal: true

Pet = Struct.new(:id, :name) do
  def persisted?
    true
  end
end
Car = Struct.new(:id, :maker_id) do
  def persisted?
    true
  end
end
Maker = Struct.new(:id, :name)
Interest = Struct.new(:id, :name)

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

INTERESTS = [
  Interest.new(1, "Science"),
  Interest.new(2, "Technology"),
  Interest.new(3, "Engineering"),
  Interest.new(4, "Math")
].freeze

class Info
  attr_accessor :birthdate, :biography, :pets, :car, :interests

  def initialize
    @birthdate = Date.parse("1990-01-01")
    @biography = false
    @pets = [
      Pet.new(1, "Fido"),
      Pet.new(2, "Buddy")
    ]
    @car = Car.new(10, 1)
    @interests = [1, 3] # Science and Engineering
  end

  def persisted?
    false
  end

  def model_name
    self.class.model_name
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Info")
  end
end

class FormObject < EasyForm::Rails::Base
  attr_accessor :helpers

  resource_model Info

  element :birthdate do
    input(type: :text, class: "form-control")
    output(type: :date, presence: true)

    def value
      super.strftime("%Y-%m-%d")
    end
  end

  element :biography do
    input(type: :checkbox)
    label(text: "Biography", class: "form-label")
    output(type: :bool, presence: true)
  end

  element :interests do
    input(type: :checkbox)
    output(type: :array, of: :integer, presence: true)
    options(INTERESTS.map(&:to_a))
    label(class: "form-label")
  end

  subform :car do
    element :maker_id do
      input(type: :radio, class: "form-control")
      output(type: :string, presence: true)
      options(MAKERS.map(&:to_a))
    end

    def render_element(element)
      div(class: "col-md-3") do
        render_label(element)
      end
      div(class: "col-md-9") do
        render_input(element)
        render_inline_errors(element) if element.tags[:errors]
      end
    end
  end

  many :pets do
    subform do
      element :id do
        input(type: :select, multiple: true, class: "form-control")
        output(type: :integer, presence: true)
        options(PETS.map(&:to_a))
        label(text: "Pets", class: "form-label")
      end

      def render_element(element)
        div(class: "col-md-3") do
          render_label(element)
        end
        div(class: "col-md-9") do
          render_input(element)
          render_inline_errors(element) if element.tags[:errors]
        end
      end
    end
  end

  def render_element(element)
    div(class: "col-md-3") do
      render_label(element)
    end
    div(class: "col-md-9") do
      render_input(element)
      render_inline_errors(element) if element.tags[:errors]
    end
  end

  def view_template
    div(class: "row") do
      super
    end
  end
end

class ViewHelpers
  def polymorphic_path(_options)
    "/create"
  end

  def form_authenticity_token
    "XD2kMuxmzYBT2emHESuqFrxJKlwKZnJPmQsL9zBxby2BtSqUzQPVNMJfF_3bbG9UksL2Gevrt803ZEBGnRixTg"
  end
end

RSpec.describe "FormObject" do
  let(:expected_html) do
    '<div class="row">' \
      '<form method="post" action="/create" accept-charset="UTF-8">' \
        '<input name="utf8" type="hidden" value="✓" autocomplete="off">' \
        '<input name="authenticity_token" type="hidden" value="XD2kMuxmzYBT2emHESuqFrxJKlwKZnJPmQsL9zBxby2BtSqUzQPVNMJfF_3bbG9UksL2Gevrt803ZEBGnRixTg">' \
        '<input name="_method" type="hidden" value="post" autocomplete="off">' \
        '<div class="col-md-3">' \
          '<label for="info_birthdate">Birthdate</label>' \
        "</div>" \
        '<div class="col-md-9">' \
          '<input type="text" class="form-control" name="info[birthdate]" id="info_birthdate" value="1990-01-01">' \
        "</div>" \
        '<div class="col-md-3">' \
          '<label for="info_biography" class="form-label">Biography</label>' \
        "</div>" \
        '<div class="col-md-9">' \
          '<input name="info[biography]" type="hidden" value="0" autocomplete="off">' \
          '<input type="checkbox" name="info[biography]" id="info_biography" value="1">' \
        "</div>" \
        '<div class="col-md-3">' \
        "</div>" \
        '<div class="col-md-9">' \
          '<input type="checkbox" name="info[interests][]" id="info_interests_1" value="1" checked>' \
          '<label for="info_interests_1" class="form-label">Science</label>' \
          '<input type="checkbox" name="info[interests][]" id="info_interests_2" value="2">' \
          '<label for="info_interests_2" class="form-label">Technology</label>' \
          '<input type="checkbox" name="info[interests][]" id="info_interests_3" value="3" checked>' \
          '<label for="info_interests_3" class="form-label">Engineering</label>' \
          '<input type="checkbox" name="info[interests][]" id="info_interests_4" value="4">' \
          '<label for="info_interests_4" class="form-label">Math</label>' \
        "</div>" \
        '<div class="col-md-3">' \
        "</div>" \
        '<div class="col-md-9">' \
          '<label for="info_car_attributes_maker_id">Toyota</label>' \
          '<input type="radio" class="form-control" name="info[car_attributes][maker_id]" id="info_car_attributes_maker_id" value="1" checked>' \
          '<label for="info_car_attributes_maker_id">Ford</label>' \
          '<input type="radio" class="form-control" name="info[car_attributes][maker_id]" id="info_car_attributes_maker_id" value="2">' \
          '<label for="info_car_attributes_maker_id">Chevrolet</label>' \
          '<input type="radio" class="form-control" name="info[car_attributes][maker_id]" id="info_car_attributes_maker_id" value="3">' \
        "</div>" \
        '<input type="hidden" autocomplete="off" name="info[car_attributes][id]" id="info_car_attributes_id" value="10">' \
        '<script type="text/javascript">function easyFormRemoveSubform(event) {' \
        "\n  " \
        "event.preventDefault()" \
        "\n  " \
        'var subform = event.target.closest(".new_pets")' \
        "\n  " \
        "if (subform) { subform.remove() }" \
        "\n  " \
        'var subform = event.target.closest(".pets_subform")' \
        "\n  " \
        "if (subform) {" \
        "\n    " \
        'subform.style.display = "none"' \
        "\n    " \
        'var input = subform.querySelector("input[name*=\'_destroy\']")' \
        "\n    " \
        'if (input) { input.value = "1" }' \
        "\n  " \
        "}" \
        "\n" \
        "}" \
        "\n" \
        "</script>" \
        '<script type="text/javascript">function easyFormAddSubform(event) {' \
        "\n  " \
        "event.preventDefault()" \
        "\n  " \
        'var template = document.querySelector("#pets_template")' \
        "\n  " \
        "const content = template.innerHTML.replace(/NEW_RECORD/g, new Date().getTime().toString())" \
        "\n  " \
        "var beforeElement = event.target.closest(event.target.dataset.insertBeforeSelector)" \
        "\n  " \
        "if (beforeElement) {" \
        "\n    " \
        'beforeElement.insertAdjacentHTML("beforebegin", content)' \
        "\n  " \
        "} else {" \
        "\n    " \
        'event.target.parentElement.insertAdjacentHTML("beforebegin", content)' \
        "\n  " \
        "}" \
        "\n" \
        "}" \
        "\n" \
        "</script>" \
        '<div id="pets_0" class="pets_subform">' \
          '<div class="col-md-3">' \
            '<label for="info_pets_attributes_0_id" class="form-label">Pets</label>' \
          "</div>" \
          '<div class="col-md-9">' \
            '<select multiple class="form-control" name="info[pets_attributes][0][id]" id="info_pets_attributes_0_id">' \
            '<option value="1" selected>Fido</option>' \
            '<option value="2">Buddy</option>' \
            '<option value="3">Max</option>' \
            '<option value="4">Bella</option>' \
            '<option value="5">Luna</option>' \
            "</select>" \
          "</div>" \
          '<input type="hidden" autocomplete="off" value="0" name="info[pets_attributes][0][_destroy]" id="info_pets_attributes_0__destroy">' \
        "</div>" \
        '<div id="pets_1" class="pets_subform">' \
          '<div class="col-md-3">' \
            '<label for="info_pets_attributes_1_id" class="form-label">Pets</label>' \
          "</div>" \
          '<div class="col-md-9">' \
            '<select multiple class="form-control" name="info[pets_attributes][1][id]" id="info_pets_attributes_1_id">' \
            '<option value="1">Fido</option>' \
            '<option value="2" selected>Buddy</option>' \
            '<option value="3">Max</option>' \
            '<option value="4">Bella</option>' \
            '<option value="5">Luna</option>' \
            "</select>" \
          "</div>" \
          '<input type="hidden" autocomplete="off" value="0" name="info[pets_attributes][1][_destroy]" id="info_pets_attributes_1__destroy">' \
        "</div>" \
        '<template id="pets_template">' \
          '<div class="new_pets">' \
            '<div class="col-md-3">' \
              '<label for="info_pets_attributes_NEW_RECORD_id" class="form-label">Pets</label>' \
            "</div>" \
            '<div class="col-md-9">' \
              '<select multiple class="form-control" name="info[pets_attributes][NEW_RECORD][id]" id="info_pets_attributes_NEW_RECORD_id">' \
              '<option value="1">Fido</option>' \
              '<option value="2">Buddy</option>' \
              '<option value="3">Max</option>' \
              '<option value="4">Bella</option>' \
              '<option value="5">Luna</option>' \
              "</select>" \
            "</div>" \
          "</div>" \
        "</template>" \
        '<input name="commit" type="submit" value="Create Info">' \
      "</form>" \
    "</div>"
  end
  it "renders a form with nested elements" do
    form = FormObject.new(model: Info.new)
    form.helpers = ViewHelpers.new
    html = form.call
    expect(html).to eq(expected_html)
    schema = form.class.params_definition.new(info: { birthdate: "1990-01-01", biography: true, interests: [1, 3], pets_attributes: [{ id: 1 }, { id: 2 }],
                                                      car_attributes: { id: 10, maker_id: 1 } })
    expect(schema.info.birthdate).to eq(Date.parse("1990-01-01"))
    expect(schema.info.biography).to eq(true)
    expect(schema.info.interests.to_a).to eq([1, 3])
    expect(schema.info.pets_attributes.map(&:id)).to eq([1, 2])
    expect(schema.info.car_attributes.maker_id).to eq("1")
    expect(schema.info.car_attributes.to_h).to eq(id: 10, maker_id: "1")
  end

  it "accepts params object and gets inputs' values from it" do
    # Create a simple params object that mimics Rails params
    params = FormObject.params_definition.new(
      info: {
        birthdate: "1985-05-15",
        biography: "1",
        interests: %w[2 4],
        pets_attributes: [{ id: 3 }, { id: 5 }],
        car_attributes: { id: 15, maker_id: 2 }
      }
    )

    form = FormObject.new(model: Info.new, params: params)
    form.helpers = ViewHelpers.new
    html = form.call

    # Expected HTML with params values instead of model values
    expected_params_html = '<div class="row">' \
      '<form method="post" action="/create" accept-charset="UTF-8">' \
        '<input name="utf8" type="hidden" value="✓" autocomplete="off">' \
        '<input name="authenticity_token" type="hidden" value="XD2kMuxmzYBT2emHESuqFrxJKlwKZnJPmQsL9zBxby2BtSqUzQPVNMJfF_3bbG9UksL2Gevrt803ZEBGnRixTg">' \
        '<input name="_method" type="hidden" value="post" autocomplete="off">' \
        '<div class="col-md-3">' \
          '<label for="info_birthdate">Birthdate</label>' \
        "</div>" \
        '<div class="col-md-9">' \
          '<input type="text" class="form-control" name="info[birthdate]" id="info_birthdate" value="1985-05-15">' \
        "</div>" \
        '<div class="col-md-3">' \
          '<label for="info_biography" class="form-label">Biography</label>' \
        "</div>" \
        '<div class="col-md-9">' \
          '<input name="info[biography]" type="hidden" value="0" autocomplete="off">' \
          '<input type="checkbox" name="info[biography]" id="info_biography" value="1" checked>' \
        "</div>" \
        '<div class="col-md-3">' \
        "</div>" \
        '<div class="col-md-9">' \
          '<input type="checkbox" name="info[interests][]" id="info_interests_1" value="1">' \
          '<label for="info_interests_1" class="form-label">Science</label>' \
          '<input type="checkbox" name="info[interests][]" id="info_interests_2" value="2" checked>' \
          '<label for="info_interests_2" class="form-label">Technology</label>' \
          '<input type="checkbox" name="info[interests][]" id="info_interests_3" value="3">' \
          '<label for="info_interests_3" class="form-label">Engineering</label>' \
          '<input type="checkbox" name="info[interests][]" id="info_interests_4" value="4" checked>' \
          '<label for="info_interests_4" class="form-label">Math</label>' \
        "</div>" \
        '<div class="col-md-3">' \
        "</div>" \
        '<div class="col-md-9">' \
          '<label for="info_car_attributes_maker_id">Toyota</label>' \
          '<input type="radio" class="form-control" name="info[car_attributes][maker_id]" id="info_car_attributes_maker_id" value="1">' \
          '<label for="info_car_attributes_maker_id">Ford</label>' \
          '<input type="radio" class="form-control" name="info[car_attributes][maker_id]" id="info_car_attributes_maker_id" value="2">' \
          '<label for="info_car_attributes_maker_id">Chevrolet</label>' \
          '<input type="radio" class="form-control" name="info[car_attributes][maker_id]" id="info_car_attributes_maker_id" value="3">' \
        "</div>" \
        '<input type="hidden" autocomplete="off" name="info[car_attributes][id]" id="info_car_attributes_id" value="15">' \
        '<script type="text/javascript">function easyFormRemoveSubform(event) {' \
        "\n  " \
        "event.preventDefault()" \
        "\n  " \
        'var subform = event.target.closest(".new_pets")' \
        "\n  " \
        "if (subform) { subform.remove() }" \
        "\n  " \
        'var subform = event.target.closest(".pets_subform")' \
        "\n  " \
        "if (subform) {" \
        "\n    " \
        'subform.style.display = "none"' \
        "\n    " \
        'var input = subform.querySelector("input[name*=\'_destroy\']")' \
        "\n    " \
        'if (input) { input.value = "1" }' \
        "\n  " \
        "}" \
        "\n" \
        "}" \
        "\n" \
        "</script>" \
        '<script type="text/javascript">function easyFormAddSubform(event) {' \
        "\n  " \
        "event.preventDefault()" \
        "\n  " \
        'var template = document.querySelector("#pets_template")' \
        "\n  " \
        "const content = template.innerHTML.replace(/NEW_RECORD/g, new Date().getTime().toString())" \
        "\n  " \
        "var beforeElement = event.target.closest(event.target.dataset.insertBeforeSelector)" \
        "\n  " \
        "if (beforeElement) {" \
        "\n    " \
        'beforeElement.insertAdjacentHTML("beforebegin", content)' \
        "\n  " \
        "} else {" \
        "\n    " \
        'event.target.parentElement.insertAdjacentHTML("beforebegin", content)' \
        "\n  " \
        "}" \
        "\n" \
        "}" \
        "\n" \
        "</script>" \
        '<div id="pets_0" class="pets_subform">' \
          '<div class="col-md-3">' \
            '<label for="info_pets_attributes_0_id" class="form-label">Pets</label>' \
          "</div>" \
          '<div class="col-md-9">' \
            '<select multiple class="form-control" name="info[pets_attributes][0][id]" id="info_pets_attributes_0_id">' \
            '<option value="1">Fido</option>' \
            '<option value="2">Buddy</option>' \
            '<option value="3" selected>Max</option>' \
            '<option value="4">Bella</option>' \
            '<option value="5">Luna</option>' \
            "</select>" \
          "</div>" \
        "</div>" \
        '<div id="pets_1" class="pets_subform">' \
          '<div class="col-md-3">' \
            '<label for="info_pets_attributes_1_id" class="form-label">Pets</label>' \
          "</div>" \
          '<div class="col-md-9">' \
            '<select multiple class="form-control" name="info[pets_attributes][1][id]" id="info_pets_attributes_1_id">' \
            '<option value="1">Fido</option>' \
            '<option value="2">Buddy</option>' \
            '<option value="3">Max</option>' \
            '<option value="4">Bella</option>' \
            '<option value="5" selected>Luna</option>' \
            "</select>" \
          "</div>" \
        "</div>" \
        '<template id="pets_template">' \
          '<div class="new_pets">' \
            '<div class="col-md-3">' \
              '<label for="info_pets_attributes_NEW_RECORD_id" class="form-label">Pets</label>' \
            "</div>" \
            '<div class="col-md-9">' \
              '<select multiple class="form-control" name="info[pets_attributes][NEW_RECORD][id]" id="info_pets_attributes_NEW_RECORD_id">' \
              '<option value="1">Fido</option>' \
              '<option value="2">Buddy</option>' \
              '<option value="3">Max</option>' \
              '<option value="4">Bella</option>' \
              '<option value="5">Luna</option>' \
              "</select>" \
            "</div>" \
          "</div>" \
        "</template>" \
        '<input name="commit" type="submit" value="Create Info">' \
      "</form>" \
    "</div>"
    expect(html).to eq(expected_params_html)
  end

  it "displays inline errors when params have validation errors" do
    # Create params with validation errors
    params = FormObject.params_definition.new(
      info: {
        birthdate: "invalid-date",
        biography: "",
        pets_attributes: [{ id: nil }, { id: nil }],
        car_attributes: { id: 15, maker_id: nil }
      }
    )

    params.valid?

    form = FormObject.new(model: Info.new, params: params)
    form.helpers = ViewHelpers.new
    html = form.call

    expected_html = '<div class="row">' \
  '<form method="post" action="/create" accept-charset="UTF-8">' \
    '<input name="utf8" type="hidden" value="✓" autocomplete="off">' \
    '<input name="authenticity_token" type="hidden" value="XD2kMuxmzYBT2emHESuqFrxJKlwKZnJPmQsL9zBxby2BtSqUzQPVNMJfF_3bbG9UksL2Gevrt803ZEBGnRixTg">' \
    '<input name="_method" type="hidden" value="post" autocomplete="off">' \
    '<div class="col-md-3">' \
      '<label for="info_birthdate">Birthdate</label>' \
    "</div>" \
    '<div class="col-md-9">' \
      '<input type="text" class="form-control" name="info[birthdate]" id="info_birthdate">' \
      '<div class="error-messages">can&#39;t be blank</div>' \
    "</div>" \
    '<div class="col-md-3">' \
      '<label for="info_biography" class="form-label">Biography</label>' \
    "</div>" \
    '<div class="col-md-9">' \
      '<input name="info[biography]" type="hidden" value="0" autocomplete="off">' \
      '<input type="checkbox" name="info[biography]" id="info_biography" value="1">' \
      '<div class="error-messages">can&#39;t be blank</div>' \
    "</div>" \
    '<div class="col-md-3">' \
    "</div>" \
    '<div class="col-md-9">' \
      '<input type="checkbox" name="info[interests][]" id="info_interests_1" value="1">' \
      '<label for="info_interests_1" class="form-label">Science</label>' \
      '<input type="checkbox" name="info[interests][]" id="info_interests_2" value="2">' \
      '<label for="info_interests_2" class="form-label">Technology</label>' \
      '<input type="checkbox" name="info[interests][]" id="info_interests_3" value="3">' \
      '<label for="info_interests_3" class="form-label">Engineering</label>' \
      '<input type="checkbox" name="info[interests][]" id="info_interests_4" value="4">' \
      '<label for="info_interests_4" class="form-label">Math</label>' \
    "</div>" \
    '<div class="col-md-3">' \
    "</div>" \
    '<div class="col-md-9">' \
      '<label for="info_car_attributes_maker_id">Toyota</label>' \
      '<input type="radio" class="form-control" name="info[car_attributes][maker_id]" id="info_car_attributes_maker_id" value="1">' \
      '<label for="info_car_attributes_maker_id">Ford</label>' \
      '<input type="radio" class="form-control" name="info[car_attributes][maker_id]" id="info_car_attributes_maker_id" value="2">' \
      '<label for="info_car_attributes_maker_id">Chevrolet</label>' \
      '<input type="radio" class="form-control" name="info[car_attributes][maker_id]" id="info_car_attributes_maker_id" value="3">' \
      '<div class="error-messages">can&#39;t be blank</div>' \
    "</div>" \
    '<input type="hidden" autocomplete="off" name="info[car_attributes][id]" id="info_car_attributes_id" value="15">' \
    '<script type="text/javascript">function easyFormRemoveSubform(event) {' \
    "\n  " \
    "event.preventDefault()" \
    "\n  " \
    'var subform = event.target.closest(".new_pets")' \
    "\n  " \
    "if (subform) { subform.remove() }" \
    "\n  " \
    'var subform = event.target.closest(".pets_subform")' \
    "\n  " \
    "if (subform) {" \
    "\n    " \
    'subform.style.display = "none"' \
    "\n    " \
    'var input = subform.querySelector("input[name*=\'_destroy\']")' \
    "\n    " \
    'if (input) { input.value = "1" }' \
    "\n  " \
    "}" \
    "\n" \
    "}" \
    "\n" \
    "</script>" \
    '<script type="text/javascript">function easyFormAddSubform(event) {' \
    "\n  " \
    "event.preventDefault()" \
    "\n  " \
    'var template = document.querySelector("#pets_template")' \
    "\n  " \
    "const content = template.innerHTML.replace(/NEW_RECORD/g, new Date().getTime().toString())" \
    "\n  " \
    "var beforeElement = event.target.closest(event.target.dataset.insertBeforeSelector)" \
    "\n  " \
    "if (beforeElement) {" \
    "\n    " \
    'beforeElement.insertAdjacentHTML("beforebegin", content)' \
    "\n  " \
    "} else {" \
    "\n    " \
    'event.target.parentElement.insertAdjacentHTML("beforebegin", content)' \
    "\n  " \
    "}" \
    "\n" \
    "}" \
    "\n" \
    "</script>" \
    '<div id="pets_0" class="new_pets">' \
      '<div class="col-md-3">' \
        '<label for="info_pets_attributes_0_id" class="form-label">Pets</label>' \
      "</div>" \
      '<div class="col-md-9">' \
        '<select multiple class="form-control" name="info[pets_attributes][0][id]" id="info_pets_attributes_0_id">' \
        '<option value="1">Fido</option>' \
        '<option value="2">Buddy</option>' \
        '<option value="3">Max</option>' \
        '<option value="4">Bella</option>' \
        '<option value="5">Luna</option>' \
        "</select>" \
        '<div class="error-messages">can&#39;t be blank</div>' \
      "</div>" \
    "</div>" \
    '<div id="pets_1" class="new_pets">' \
      '<div class="col-md-3">' \
        '<label for="info_pets_attributes_1_id" class="form-label">Pets</label>' \
      "</div>" \
      '<div class="col-md-9">' \
        '<select multiple class="form-control" name="info[pets_attributes][1][id]" id="info_pets_attributes_1_id">' \
        '<option value="1">Fido</option>' \
        '<option value="2">Buddy</option>' \
        '<option value="3">Max</option>' \
        '<option value="4">Bella</option>' \
        '<option value="5">Luna</option>' \
        "</select>" \
        '<div class="error-messages">can&#39;t be blank</div>' \
      "</div>" \
    "</div>" \
    '<template id="pets_template">' \
      '<div class="new_pets">' \
        '<div class="col-md-3">' \
          '<label for="info_pets_attributes_NEW_RECORD_id" class="form-label">Pets</label>' \
        "</div>" \
        '<div class="col-md-9">' \
          '<select multiple class="form-control" name="info[pets_attributes][NEW_RECORD][id]" id="info_pets_attributes_NEW_RECORD_id">' \
          '<option value="1">Fido</option>' \
          '<option value="2">Buddy</option>' \
          '<option value="3">Max</option>' \
          '<option value="4">Bella</option>' \
          '<option value="5">Luna</option>' \
          "</select>" \
        "</div>" \
      "</div>" \
    "</template>" \
    '<input name="commit" type="submit" value="Create Info">' \
  "</form>" \
"</div>"

    expect(html).to eq(expected_html)
  end
end

# rubocop:enable Metrics/BlockLength, Layout/LineLength
