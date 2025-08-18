# frozen_string_literal: true

class TestForm < EasyForm::Base
  element :biography do
    # input_config do
    #   html do
    #     type :date
    #     id "birthday"
    #     autocomplete "off"
    #     aria label: "Birthday"
    #     class_list "form-control", "date-picker"
    #   end
    #   output do
    #     type :date
    #     validates(presence: { message: "Birthday is required" })
    #     normalize do |value|
    #       value.to_date
    #     rescue StandardError
    #       nil
    #     end
    #     default "1990-01-01"
    #   end
    # end

    def view_template
      div(class: "form-group") do
        label(for: name) { name }
        input(**html_attributes)
      end
    end
  end

  element :birthday do
    # input_config do
    #   html { type :date }
    #   output { validates(presence: true) }
    # end
  end

  def view_template
    div(class: "row") do
      div(class: "col-md-6") do
        render elements[:birthday]
      end
      div(class: "col-md-6") do
        render elements[:biography]
      end
    end
  end
end

RSpec.describe EasyForm do
  it "renders a form with a checkbox" do
    form = TestForm.new(Object.new)
    html = form.call
    expect(html).to eq(
      '<div class="row"><div class="col-md-6"></div><div class="col-md-6"><div class="form-group"><input type="date" id="birthday" autocomplete="off" aria-label="Birthday" name="biography" class="form-control date-picker"></div></div></div>'
    )
  end
end
