# frozen_string_literal: true

class Profile < Struct.new(:id, :name)
  def persisted?
    false
  end
end

class Device < Struct.new(:id, :name)
  def persisted?
    false
  end
end
class User < Struct.new(:id, :email, :password, :password_confirmation, :profile, :pets)
  def initialize
    @id = 1
  end

  def persisted?
    true
  end

  def profile
    @profile ||= Profile.new(1, "John Doe")
  end

  def devices
    @devices ||= [Device.new(1, "Fido"), Device.new(2, "Buddy")]
  end

  def model_name
    self.class.model_name
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "User")
  end
end

class RegistrationForm < ActionForm::Rails::Base
  attr_accessor :helpers

  resource_model User

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

  many :devices, default: [{}] do
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

  def check_devices_name?
    true
  end
end

class Helpers
  # def polymorphic_path(_options)
  #   "/create"
  # end

  def form_authenticity_token
    "XD2kMuxmzYBT2emHESuqFrxJKlwKZnJPmQsL9zBxby2BtSqUzQPVNMJfF_3bbG9UksL2Gevrt803ZEBGnRixTg"
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
      devices_attributes_schema do
        validates :name, presence: { if: :owner_check_devices_name? }
      end
    end
    params = child_form.params_definition.new(profile_attributes: { name: "John Doe" }, email: "john.doe@example.com", password: "password", password_confirmation: "password2")
    expect(params.class.form_class).to eq(child_form)
    form = params.create_form(action: '/create', method: 'PUT')
    form.helpers = Helpers.new
    expect(form.call).to match(%r{form method="post" action="/create"})
    expect(form.scope).to eq(:user)
    expect(form.html_options[:action]).to eq('/create')
    expect(params).to be_invalid
    expect(params.profile_attributes.name).to eq("John Doe")
    expect(params.email).to eq("john.doe@example.com")
    expect(params.password).to eq("password")
    expect(params.password_confirmation).to eq("password2")
    expect(params.errors.full_messages).to eq(["Devices attributes[0] name can't be blank", "Password confirmation doesn't match Password"])
  end
end