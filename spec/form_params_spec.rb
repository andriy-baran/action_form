
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

  def check_password_confirmation?
    true
  end

  def check_password?
    true
  end

  def check_profile_name?
    true
  end

  def check_pets_name?
    true
  end
end

RSpec.describe "Form params" do
  it "renders a form with params" do
    child_form = Class.new(RegistrationForm)
    child_form.params do
      validates :password, presence: { if: :owner_check_password? }
      validates :password_confirmation, presence: { if: :owner_check_password_confirmation? }
      validates :password, confirmation: { if: :owner_check_password? }
      profile_attributes_schema do
        validates :name, presence: { if: :owner_check_profile_name? }
      end
      pets_attributes_schema do
        validates :name, presence: { if: :owner_check_pets_name? }
      end
    end
    params = child_form.params_definition.new(profile_attributes: { name: "John Doe" }, email: "john.doe@example.com", password: "password", password_confirmation: "password2")
    expect(params.class.form_class).to eq(child_form)
    form = params.create_form
    expect(form.action_name).to eq(:create)
    expect(params).to be_invalid
    expect(params.profile_attributes.name).to eq("John Doe")
    expect(params.email).to eq("john.doe@example.com")
    expect(params.password).to eq("password")
    expect(params.password_confirmation).to eq("password2")
    expect(params.errors.full_messages).to eq(["Pets attributes[0] name can't be blank", "Password confirmation doesn't match Password"])
  end
end