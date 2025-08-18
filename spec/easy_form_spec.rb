# frozen_string_literal: true

RSpec.describe EasyForm do
  it "has a version number" do
    expect(EasyForm::VERSION).not_to be nil
  end

  it "renders checkbox with hidden field" do
    form = EasyForm::Base.new(Object.new)
    html = form.checkbox(:biography)
    expect(html).to eq(
      '<input name="biography" type="hidden" value="0" autocomplete="off"><input type="checkbox" value="1" name="biography" id="biography">'
    )
  end

  it "renders label with text" do
    form = EasyForm::Base.new(Object.new)
    html = form.label(:biography, "Biography")
    expect(html).to eq('<label for="biography">Biography</label>')
  end

  it "renders radio buttons and labels for flavors" do
    form = EasyForm::Base.new(Object.new)
    html = [
      form.radio_button(:flavor, "chocolate_chip"),
      form.label(:flavor_chocolate_chip, "Chocolate Chip"),
      form.radio_button(:flavor, "vanilla"),
      form.label(:flavor_vanilla, "Vanilla"),
      form.radio_button(:flavor, "hazelnut"),
      form.label(:flavor_hazelnut, "Hazelnut")
    ].join(" ")

    expect(html).to eq(
      '<input type="radio" value="chocolate_chip" name="flavor" id="flavor_chocolate_chip"> ' \
      '<label for="flavor_chocolate_chip">Chocolate Chip</label> ' \
      '<input type="radio" value="vanilla" name="flavor" id="flavor_vanilla"> ' \
      '<label for="flavor_vanilla">Vanilla</label> ' \
      '<input type="radio" value="hazelnut" name="flavor" id="flavor_hazelnut"> ' \
      '<label for="flavor_hazelnut">Hazelnut</label>'
    )
  end

  it "renders password, email, telephone and url inputs" do
    form = EasyForm::Base.new(Object.new)
    html = [
      form.password_field(:password),
      form.email_field(:address),
      form.telephone_field(:phone),
      form.url_field(:homepage)
    ].join(" ")

    expect(html).to eq(
      '<input type="password" name="password" id="password"> ' \
      '<input type="email" name="address" id="address"> ' \
      '<input type="tel" name="phone" id="phone"> ' \
      '<input type="url" name="homepage" id="homepage">'
    )
  end

  it "renders textarea, hidden, number, range, search and color inputs" do
    form = EasyForm::Base.new(Object.new)
    html = [
      form.textarea(:message, size: "70x5"),
      form.hidden_field(:parent_id, value: "foo"),
      form.number_field(:price, in: 1.0..20.0, step: 0.5),
      form.range_field(:discount, in: 1..100),
      form.search_field(:name),
      form.color_field(:favorite_color)
    ].join(" ")

    expect(html).to eq(
      '<textarea name="message" id="message" cols="70" rows="5"></textarea> ' \
      '<input value="foo" autocomplete="off" type="hidden" name="parent_id" id="parent_id"> ' \
      '<input step="0.5" min="1.0" max="20.0" type="number" name="price" id="price"> ' \
      '<input min="1" max="100" type="range" name="discount" id="discount"> ' \
      '<input type="search" name="name" id="name"> ' \
      '<input value="#000000" type="color" name="favorite_color" id="favorite_color">'
    )
  end

  it "renders date, time, datetime-local, month and week inputs" do
    form = EasyForm::Base.new(Object.new)
    html = [
      form.date_field(:born_on),
      form.time_field(:started_at),
      form.datetime_local_field(:graduation_day),
      form.month_field(:birthday_month),
      form.week_field(:birthday_week)
    ].join(" ")

    expect(html).to eq(
      '<input type="date" name="born_on" id="born_on"> ' \
      '<input type="time" name="started_at" id="started_at"> ' \
      '<input type="datetime-local" name="graduation_day" id="graduation_day"> ' \
      '<input type="month" name="birthday_month" id="birthday_month"> ' \
      '<input type="week" name="birthday_week" id="birthday_week">'
    )
  end
end
