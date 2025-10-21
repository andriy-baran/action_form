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

class FormObject < ActionForm::Rails::Base
  attr_accessor :helpers

  resource_model Info

  element :birthdate do
    input(type: :text, class: "form-control")
    output(type: :date, default: Date.parse("1990-01-01"), presence: true)

    def value
      helpers.format_date(super)
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

      def html_value
        helpers.format_maker(super)
      end
    end

    element :color do
      input(type: :select, class: "form-control")
      output(type: :string, presence: true)
      label(text: "Color", class: "form-label")
      options([%w[Red red], %w[Green green], %w[Blue blue]])

      def render?
        false
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

  def format_date(date)
    date.strftime("%Y-%m-%d")
  end

  def format_maker(maker_id)
    maker_id.to_s
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
        '<script type="text/javascript">function actionFormRemoveSubform(event) {' \
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
        '<script type="text/javascript">function actionFormAddSubform(event) {' \
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
    schema = form.params_definition.new(info: { birthdate: "1990-01-01", biography: true, interests: [1, 3], pets_attributes: [{ id: 1 }, { id: 2 }],
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
        '<script type="text/javascript">function actionFormRemoveSubform(event) {' \
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
        '<script type="text/javascript">function actionFormAddSubform(event) {' \
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
      '<input type="text" class="form-control" name="info[birthdate]" id="info_birthdate" value="1990-01-01">' \
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
    '<script type="text/javascript">function actionFormRemoveSubform(event) {' \
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
    '<script type="text/javascript">function actionFormAddSubform(event) {' \
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

  it "renders a form with many nested forms and default values" do
    # Create proper objects for nested forms
    Address = Struct.new(:id, :street, :city, :zip) do
      def persisted?
        id.present?
      end
    end

    Contact = Struct.new(:id, :type, :value) do
      def persisted?
        id.present?
      end
    end

    # Create a more complex model with multiple nested collections
    class ComplexInfo
      attr_accessor :name, :pets, :addresses, :contacts

      def initialize
        @name = "John Doe"
        @pets = [
          Pet.new(1, "Fido"),
          Pet.new(2, "Buddy")
        ]
        @addresses = [
          Address.new(1, "123 Main St", "New York", "10001"),
          Address.new(2, "456 Oak Ave", "Boston", "02101")
        ]
        @contacts = [
          Contact.new(1, "email", "john@example.com"),
          Contact.new(2, "phone", "555-1234")
        ]
      end

      def persisted?
        false
      end

      def model_name
        self.class.model_name
      end

      def self.model_name
        ActiveModel::Name.new(self, nil, "ComplexInfo")
      end
    end

    class ComplexFormObject < ActionForm::Rails::Base
      attr_accessor :helpers

      resource_model ComplexInfo

      element :name do
        input(type: :text, default: "Default Name", class: "form-control")
        output(type: :string, presence: true)
        label(text: "Full Name", class: "form-label")
      end

      many :pets do
        subform do
          element :id do
            input(type: :select, class: "form-control", default: 1)
            output(type: :integer, presence: true)
            options(PETS.map(&:to_a))
            label(text: "Pet", class: "form-label")
          end

          element :name do
            input(type: :text, default: "New Pet", class: "form-control")
            output(type: :string, presence: true)
            label(text: "Pet Name", class: "form-label")
          end

          def render_element(element)
            div(class: "col-md-6") do
              render_label(element)
            end
            div(class: "col-md-6") do
              render_input(element)
              render_inline_errors(element) if element.tags[:errors]
            end
          end
        end
      end

      many :addresses do
        subform do
          element :id do
            input(type: :hidden, default: nil)
            output(type: :integer)
          end

          element :street do
            input(type: :text, default: "Default Street", class: "form-control")
            output(type: :string, presence: true)
            label(text: "Street", class: "form-label")
          end

          element :city do
            input(type: :text, default: "Default City", class: "form-control")
            output(type: :string, presence: true)
            label(text: "City", class: "form-label")
          end

          element :zip do
            input(type: :text, default: "00000", class: "form-control")
            output(type: :string, presence: true)
            label(text: "ZIP Code", class: "form-label")
          end

          def render_element(element)
            div(class: "col-md-4") do
              render_label(element)
            end
            div(class: "col-md-8") do
              render_input(element)
              render_inline_errors(element) if element.tags[:errors]
            end
          end
        end
      end

      many :contacts do
        subform do
          element :id do
            input(type: :hidden, default: nil)
            output(type: :integer)
          end

          element :type do
            input(type: :select, default: "email", class: "form-control")
            output(type: :string, presence: true)
            options([%w[Email email], %w[Phone phone], %w[Fax fax]])
            label(text: "Contact Type", class: "form-label")
          end

          element :value do
            input(type: :text, default: "default@example.com", class: "form-control")
            output(type: :string, presence: true)
            label(text: "Contact Value", class: "form-label")
          end

          def render_element(element)
            div(class: "col-md-6") do
              render_label(element)
            end
            div(class: "col-md-6") do
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

    # Test with model data
    form = ComplexFormObject.new(model: ComplexInfo.new)
    form.helpers = ViewHelpers.new
    html = form.call

    # Create expected HTML for the complex form
    expected_complex_html = '<div class="row">' \
      '<form method="post" action="/create" accept-charset="UTF-8">' \
        '<input name="utf8" type="hidden" value="✓" autocomplete="off">' \
        '<input name="authenticity_token" type="hidden" value="XD2kMuxmzYBT2emHESuqFrxJKlwKZnJPmQsL9zBxby2BtSqUzQPVNMJfF_3bbG9UksL2Gevrt803ZEBGnRixTg">' \
        '<input name="_method" type="hidden" value="post" autocomplete="off">' \
        '<div class="col-md-3">' \
          '<label for="complex_info_name" class="form-label">Full Name</label>' \
        "</div>" \
        '<div class="col-md-9">' \
          '<input type="text" class="form-control" name="complex_info[name]" id="complex_info_name" value="John Doe">' \
        "</div>" \
        '<script type="text/javascript">function actionFormRemoveSubform(event) {' \
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
        '<script type="text/javascript">function actionFormAddSubform(event) {' \
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
          '<div class="col-md-6">' \
            '<label for="complex_info_pets_attributes_0_id" class="form-label">Pet</label>' \
          "</div>" \
          '<div class="col-md-6">' \
            '<select class="form-control" name="complex_info[pets_attributes][0][id]" id="complex_info_pets_attributes_0_id">' \
            '<option value="1" selected>Fido</option>' \
            '<option value="2">Buddy</option>' \
            '<option value="3">Max</option>' \
            '<option value="4">Bella</option>' \
            '<option value="5">Luna</option>' \
            "</select>" \
          "</div>" \
          '<div class="col-md-6">' \
            '<label for="complex_info_pets_attributes_0_name" class="form-label">Pet Name</label>' \
          "</div>" \
          '<div class="col-md-6">' \
            '<input type="text" class="form-control" name="complex_info[pets_attributes][0][name]" id="complex_info_pets_attributes_0_name" value="Fido">' \
          "</div>" \
          '<input type="hidden" autocomplete="off" value="0" name="complex_info[pets_attributes][0][_destroy]" id="complex_info_pets_attributes_0__destroy">' \
        "</div>" \
        '<div id="pets_1" class="pets_subform">' \
          '<div class="col-md-6">' \
            '<label for="complex_info_pets_attributes_1_id" class="form-label">Pet</label>' \
          "</div>" \
          '<div class="col-md-6">' \
            '<select class="form-control" name="complex_info[pets_attributes][1][id]" id="complex_info_pets_attributes_1_id">' \
            '<option value="1">Fido</option>' \
            '<option value="2" selected>Buddy</option>' \
            '<option value="3">Max</option>' \
            '<option value="4">Bella</option>' \
            '<option value="5">Luna</option>' \
            "</select>" \
          "</div>" \
          '<div class="col-md-6">' \
            '<label for="complex_info_pets_attributes_1_name" class="form-label">Pet Name</label>' \
          "</div>" \
          '<div class="col-md-6">' \
            '<input type="text" class="form-control" name="complex_info[pets_attributes][1][name]" id="complex_info_pets_attributes_1_name" value="Buddy">' \
          "</div>" \
          '<input type="hidden" autocomplete="off" value="0" name="complex_info[pets_attributes][1][_destroy]" id="complex_info_pets_attributes_1__destroy">' \
        "</div>" \
        '<template id="pets_template">' \
          '<div class="new_pets">' \
            '<div class="col-md-6">' \
              '<label for="complex_info_pets_attributes_NEW_RECORD_id" class="form-label">Pet</label>' \
            "</div>" \
            '<div class="col-md-6">' \
              '<select class="form-control" name="complex_info[pets_attributes][NEW_RECORD][id]" id="complex_info_pets_attributes_NEW_RECORD_id">' \
              '<option value="1" selected>Fido</option>' \
              '<option value="2">Buddy</option>' \
              '<option value="3">Max</option>' \
              '<option value="4">Bella</option>' \
              '<option value="5">Luna</option>' \
              "</select>" \
            "</div>" \
            '<div class="col-md-6">' \
              '<label for="complex_info_pets_attributes_NEW_RECORD_name" class="form-label">Pet Name</label>' \
            "</div>" \
            '<div class="col-md-6">' \
              '<input type="text" class="form-control" name="complex_info[pets_attributes][NEW_RECORD][name]" id="complex_info_pets_attributes_NEW_RECORD_name" value="New Pet">' \
            "</div>" \
          "</div>" \
        "</template>" \
        '<script type="text/javascript">function actionFormRemoveSubform(event) {' \
        "\n  " \
        "event.preventDefault()" \
        "\n  " \
        'var subform = event.target.closest(".new_addresses")' \
        "\n  " \
        "if (subform) { subform.remove() }" \
        "\n  " \
        'var subform = event.target.closest(".addresses_subform")' \
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
        '<script type="text/javascript">function actionFormAddSubform(event) {' \
        "\n  " \
        "event.preventDefault()" \
        "\n  " \
        'var template = document.querySelector("#addresses_template")' \
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
        '<div id="addresses_0" class="addresses_subform">' \
          '<input type="hidden" name="complex_info[addresses_attributes][0][id]" id="complex_info_addresses_attributes_0_id" value="1">' \
          '<div class="col-md-4">' \
            '<label for="complex_info_addresses_attributes_0_street" class="form-label">Street</label>' \
          "</div>" \
          '<div class="col-md-8">' \
            '<input type="text" class="form-control" name="complex_info[addresses_attributes][0][street]" id="complex_info_addresses_attributes_0_street" value="123 Main St">' \
          "</div>" \
          '<div class="col-md-4">' \
            '<label for="complex_info_addresses_attributes_0_city" class="form-label">City</label>' \
          "</div>" \
          '<div class="col-md-8">' \
            '<input type="text" class="form-control" name="complex_info[addresses_attributes][0][city]" id="complex_info_addresses_attributes_0_city" value="New York">' \
          "</div>" \
          '<div class="col-md-4">' \
            '<label for="complex_info_addresses_attributes_0_zip" class="form-label">ZIP Code</label>' \
          "</div>" \
          '<div class="col-md-8">' \
            '<input type="text" class="form-control" name="complex_info[addresses_attributes][0][zip]" id="complex_info_addresses_attributes_0_zip" value="10001">' \
          "</div>" \
          '<input type="hidden" autocomplete="off" value="0" name="complex_info[addresses_attributes][0][_destroy]" id="complex_info_addresses_attributes_0__destroy">' \
        "</div>" \
        '<div id="addresses_1" class="addresses_subform">' \
          '<input type="hidden" name="complex_info[addresses_attributes][1][id]" id="complex_info_addresses_attributes_1_id" value="2">' \
          '<div class="col-md-4">' \
            '<label for="complex_info_addresses_attributes_1_street" class="form-label">Street</label>' \
          "</div>" \
          '<div class="col-md-8">' \
            '<input type="text" class="form-control" name="complex_info[addresses_attributes][1][street]" id="complex_info_addresses_attributes_1_street" value="456 Oak Ave">' \
          "</div>" \
          '<div class="col-md-4">' \
            '<label for="complex_info_addresses_attributes_1_city" class="form-label">City</label>' \
          "</div>" \
          '<div class="col-md-8">' \
            '<input type="text" class="form-control" name="complex_info[addresses_attributes][1][city]" id="complex_info_addresses_attributes_1_city" value="Boston">' \
          "</div>" \
          '<div class="col-md-4">' \
            '<label for="complex_info_addresses_attributes_1_zip" class="form-label">ZIP Code</label>' \
          "</div>" \
          '<div class="col-md-8">' \
            '<input type="text" class="form-control" name="complex_info[addresses_attributes][1][zip]" id="complex_info_addresses_attributes_1_zip" value="02101">' \
          "</div>" \
          '<input type="hidden" autocomplete="off" value="0" name="complex_info[addresses_attributes][1][_destroy]" id="complex_info_addresses_attributes_1__destroy">' \
        "</div>" \
        '<template id="addresses_template">' \
          '<div class="new_addresses">' \
            '<input type="hidden" name="complex_info[addresses_attributes][NEW_RECORD][id]" id="complex_info_addresses_attributes_NEW_RECORD_id" value="">' \
            '<div class="col-md-4">' \
              '<label for="complex_info_addresses_attributes_NEW_RECORD_street" class="form-label">Street</label>' \
            "</div>" \
            '<div class="col-md-8">' \
              '<input type="text" class="form-control" name="complex_info[addresses_attributes][NEW_RECORD][street]" id="complex_info_addresses_attributes_NEW_RECORD_street" value="Default Street">' \
            "</div>" \
            '<div class="col-md-4">' \
              '<label for="complex_info_addresses_attributes_NEW_RECORD_city" class="form-label">City</label>' \
            "</div>" \
            '<div class="col-md-8">' \
              '<input type="text" class="form-control" name="complex_info[addresses_attributes][NEW_RECORD][city]" id="complex_info_addresses_attributes_NEW_RECORD_city" value="Default City">' \
            "</div>" \
            '<div class="col-md-4">' \
              '<label for="complex_info_addresses_attributes_NEW_RECORD_zip" class="form-label">ZIP Code</label>' \
            "</div>" \
            '<div class="col-md-8">' \
              '<input type="text" class="form-control" name="complex_info[addresses_attributes][NEW_RECORD][zip]" id="complex_info_addresses_attributes_NEW_RECORD_zip" value="00000">' \
            "</div>" \
          "</div>" \
        "</template>" \
        '<script type="text/javascript">function actionFormRemoveSubform(event) {' \
        "\n  " \
        "event.preventDefault()" \
        "\n  " \
        'var subform = event.target.closest(".new_contacts")' \
        "\n  " \
        "if (subform) { subform.remove() }" \
        "\n  " \
        'var subform = event.target.closest(".contacts_subform")' \
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
        '<script type="text/javascript">function actionFormAddSubform(event) {' \
        "\n  " \
        "event.preventDefault()" \
        "\n  " \
        'var template = document.querySelector("#contacts_template")' \
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
        '<div id="contacts_0" class="contacts_subform">' \
          '<input type="hidden" name="complex_info[contacts_attributes][0][id]" id="complex_info_contacts_attributes_0_id" value="1">' \
          '<div class="col-md-6">' \
            '<label for="complex_info_contacts_attributes_0_type" class="form-label">Contact Type</label>' \
          "</div>" \
          '<div class="col-md-6">' \
            '<select class="form-control" name="complex_info[contacts_attributes][0][type]" id="complex_info_contacts_attributes_0_type">' \
            '<option value="Email">email</option>' \
            '<option value="Phone">phone</option>' \
            '<option value="Fax">fax</option>' \
            "</select>" \
          "</div>" \
          '<div class="col-md-6">' \
            '<label for="complex_info_contacts_attributes_0_value" class="form-label">Contact Value</label>' \
          "</div>" \
          '<div class="col-md-6">' \
            '<input type="text" class="form-control" name="complex_info[contacts_attributes][0][value]" id="complex_info_contacts_attributes_0_value" value="john@example.com">' \
          "</div>" \
          '<input type="hidden" autocomplete="off" value="0" name="complex_info[contacts_attributes][0][_destroy]" id="complex_info_contacts_attributes_0__destroy">' \
        "</div>" \
        '<div id="contacts_1" class="contacts_subform">' \
          '<input type="hidden" name="complex_info[contacts_attributes][1][id]" id="complex_info_contacts_attributes_1_id" value="2">' \
          '<div class="col-md-6">' \
            '<label for="complex_info_contacts_attributes_1_type" class="form-label">Contact Type</label>' \
          "</div>" \
          '<div class="col-md-6">' \
            '<select class="form-control" name="complex_info[contacts_attributes][1][type]" id="complex_info_contacts_attributes_1_type">' \
            '<option value="Email">email</option>' \
            '<option value="Phone">phone</option>' \
            '<option value="Fax">fax</option>' \
            "</select>" \
          "</div>" \
          '<div class="col-md-6">' \
            '<label for="complex_info_contacts_attributes_1_value" class="form-label">Contact Value</label>' \
          "</div>" \
          '<div class="col-md-6">' \
            '<input type="text" class="form-control" name="complex_info[contacts_attributes][1][value]" id="complex_info_contacts_attributes_1_value" value="555-1234">' \
          "</div>" \
          '<input type="hidden" autocomplete="off" value="0" name="complex_info[contacts_attributes][1][_destroy]" id="complex_info_contacts_attributes_1__destroy">' \
        "</div>" \
        '<template id="contacts_template">' \
          '<div class="new_contacts">' \
            '<input type="hidden" name="complex_info[contacts_attributes][NEW_RECORD][id]" id="complex_info_contacts_attributes_NEW_RECORD_id" value="">' \
            '<div class="col-md-6">' \
              '<label for="complex_info_contacts_attributes_NEW_RECORD_type" class="form-label">Contact Type</label>' \
            "</div>" \
            '<div class="col-md-6">' \
              '<select class="form-control" name="complex_info[contacts_attributes][NEW_RECORD][type]" id="complex_info_contacts_attributes_NEW_RECORD_type">' \
              '<option value="Email">email</option>' \
              '<option value="Phone">phone</option>' \
              '<option value="Fax">fax</option>' \
              "</select>" \
            "</div>" \
            '<div class="col-md-6">' \
              '<label for="complex_info_contacts_attributes_NEW_RECORD_value" class="form-label">Contact Value</label>' \
            "</div>" \
            '<div class="col-md-6">' \
              '<input type="text" class="form-control" name="complex_info[contacts_attributes][NEW_RECORD][value]" id="complex_info_contacts_attributes_NEW_RECORD_value" value="default@example.com">' \
            "</div>" \
          "</div>" \
        "</template>" \
        '<input name="commit" type="submit" value="Create ComplexInfo">' \
      "</form>" \
    "</div>"

    # Verify the form renders with model data
    expect(html).to eq(expected_complex_html)

    # Test with params that override model data
    params = ComplexFormObject.params_definition.new(
      complex_info: {
        name: "Jane Smith",
        pets_attributes: [
          { id: 3, name: "Max" },
          { id: 4, name: "Bella" },
          { id: 5, name: "Luna" }
        ],
        addresses_attributes: [
          { street: "789 Pine St", city: "Seattle", zip: "98101" },
          { street: "321 Elm St", city: "Portland", zip: "97201" }
        ],
        contacts_attributes: [
          { type: "phone", value: "555-9876" },
          { type: "email", value: "jane@example.com" },
          { type: "fax", value: "555-5432" }
        ]
      }
    )

    form_with_params = ComplexFormObject.new(model: ComplexInfo.new, params: params)
    form_with_params.helpers = ViewHelpers.new
    html_with_params = form_with_params.call

    # Verify params override model data
    expect(html_with_params).to include('value="Jane Smith"')
    expect(html_with_params).to include('value="Max"')
    expect(html_with_params).to include('value="Bella"')
    expect(html_with_params).to include('value="Luna"')
    expect(html_with_params).to include('value="789 Pine St"')
    expect(html_with_params).to include('value="Seattle"')
    expect(html_with_params).to include('value="98101"')
    expect(html_with_params).to include('value="555-9876"')
    expect(html_with_params).to include('value="jane@example.com"')
    expect(html_with_params).to include('value="555-5432"')

    # Test schema validation with nested data
    schema = form_with_params.class.params_definition.new(
      complex_info: {
        name: "Test User",
        pets_attributes: [{ id: 1, name: "Test Pet" }],
        addresses_attributes: [{ street: "Test St", city: "Test City", zip: "12345" }],
        contacts_attributes: [{ type: "email", value: "test@example.com" }]
      }
    )

    expect(schema.complex_info.name).to eq("Test User")
    expect(schema.complex_info.pets_attributes.first.id).to eq(1)
    expect(schema.complex_info.pets_attributes.first.name).to eq("Test Pet")
    expect(schema.complex_info.addresses_attributes.first.street).to eq("Test St")
    expect(schema.complex_info.addresses_attributes.first.city).to eq("Test City")
    expect(schema.complex_info.addresses_attributes.first.zip).to eq("12345")
    expect(schema.complex_info.contacts_attributes.first.type).to eq("email")
    expect(schema.complex_info.contacts_attributes.first.value).to eq("test@example.com")

    # Test default values when no model data is provided
    empty_model = ComplexInfo.new
    empty_model.name = nil # Set name to nil to test default
    empty_model.pets = []
    empty_model.addresses = []
    empty_model.contacts = []

    form_empty = ComplexFormObject.new(model: empty_model)
    form_empty.helpers = ViewHelpers.new
    html_empty = form_empty.call

    # Verify default values are used when no model data
    expect(html_empty).to include('value="Default Name"')

    # Verify default values in templates for nested forms
    expect(html_empty).to include('value="New Pet"') # Default pet name in template
    expect(html_empty).to include('value="Default Street"') # Default street in template
    expect(html_empty).to include('value="Default City"') # Default city in template
    expect(html_empty).to include('value="00000"') # Default zip in template
    expect(html_empty).to include('value="default@example.com"') # Default contact value in template
  end
end

# rubocop:enable Metrics/BlockLength, Layout/LineLength
