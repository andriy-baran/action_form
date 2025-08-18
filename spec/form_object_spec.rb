# frozen_string_literal: true

class DeclarativeForm < EasyForm::Base
  element :birthdate do
    # input_config do
    #   html { type :date }
    # end

    def view_template
      div(class: "form-group") do
        label(for: @name) { @name }
        input(**html_attributes)
      end
    end
  end

  def view_template
    div(class: "row") do
      div(class: "col-md-6") do
        render elements[:birthdate]
      end
    end
  end
end

class Info
  attr_accessor :birthdate, :biography

  def initialize
    @birthdate = "1990-01-01"
    @biography = true
  end
end

RSpec.describe EasyForm do
  it "renders a form with a checkbox" do
    form = DeclarativeForm.new(Info.new)
    html = form.call
    expect(html).to eq(
      '<input name="biography" type="hidden" value="0" autocomplete="off"><input type="checkbox" value="1" name="biography" id="biography">'
    )
  end
end
