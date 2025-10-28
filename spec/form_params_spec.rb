
class RegistrationForm < ActionForm::Base
  element :email do
    input(type: :email)
    output(type: :string, presence: true)
  end
  element :password do
    input(type: :password)
    output(type: :string)
  end
  element :password_confirmation do
    input(type: :password)
    output(type: :string)
  end

  subform :profile, default: {} do
    element :name do
      input(type: :text)
      output(type: :string)
    end
  end

  many :pets, default: [{}] do
    subform do
      element :name do
        input(type: :text)
        output(type: :string)
      end
    end
  end
end

RSpec.describe "Form params" do
  it "renders a form with params" do
    secure = true
    child_form = Class.new(RegistrationForm)
    child_form.params do
      validates :password, presence: true, if: -> { secure }
      validates :password_confirmation, presence: true, if: -> { secure }
      validates :password, confirmation: true, if: -> { secure }
      profile_attributes_schema do
        validates :name, presence: true, if: -> { secure }
      end
      pets_attributes_schema do
        validates :name, presence: true, if: -> { secure }
      end
    end
    params = child_form.params_definition.new(profile_attributes: { name: "John Doe" }, email: "john.doe@example.com", password: "password", password_confirmation: "password2")
    expect(params).to be_invalid
    expect(params.profile_attributes.name).to eq("John Doe")
    expect(params.email).to eq("john.doe@example.com")
    expect(params.password).to eq("password")
    expect(params.password_confirmation).to eq("password2")
    expect(params.errors.full_messages).to eq(["Pets attributes[0] name can't be blank", "Password confirmation doesn't match Password"])
  end
end