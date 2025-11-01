# ActionForm

[![Maintainability](https://qlty.sh/gh/andriy-baran/projects/easy_params/maintainability.svg)](https://qlty.sh/gh/andriy-baran/projects/easy_params)
[![Code Coverage](https://qlty.sh/gh/andriy-baran/projects/easy_params/coverage.svg)](https://qlty.sh/gh/andriy-baran/projects/easy_params)
[![Gem Version](https://badge.fury.io/rb/action_form.svg)](https://badge.fury.io/rb/action_form)

This library allows you to build complex forms in Ruby with a simple DSL. It provides:

- A clean, declarative syntax for defining form fields and validations
- Support for nested forms
- Custom parameter validation with the `params` method
- Automatic form rendering with customizable HTML/CSS
- Built-in error handling and validation
- Integration with Rails and other Ruby web frameworks

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'action_form'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install action_form
```

### Requirements

- Ruby >= 2.7.0
- Rails >= 6.0.0 (for Rails integration)

## Concept

ActionForm is built around a modular architecture that separates form definition, data handling, and rendering concerns.

### Core Architecture

**ActionForm::Base** is the main form class that inherits from `Phlex::HTML` for rendering. It combines three key modules:

- **Elements DSL**: Provides methods like `element`, `subform`, and `many` to define form structure using block syntax, where each element can be configured with input types, labels, and validation options
- **Rendering**: Converts form elements into HTML using Phlex, handles nested forms, error display, and provides JavaScript for dynamic form interactions
- **Schema DSL**: Defines how form data is structured and validated using [EasyParams](https://github.com/andriy-baran/easy_params). It generates parameter classes that can process submitted form data and restore the form state when validation fails

### How It Works

1. **Form Definition**: You define your form using a declarative DSL with `element`, `subform`, and `many` methods
2. **Element Creation**: Each element definition creates a class that inherits from `ActionForm::Element`. The element name must correspond to a method or attribute on the object passed to the form (e.g., `element :name` expects the object to have a `name` method)
3. **Instance Building**: When the form is instantiated, it iterates through each defined element and creates an instance. Each element instance is bound to the object and can access its current values, errors, and HTML attributes
4. **Rendering**: The form renders itself using Phlex, with each element containing all the data needed to render a complete form control (input type, current value, label text, HTML attributes, validation errors, and select options)
5. **Parameter Handling**: The form automatically generates [EasyParams](https://github.com/andriy-baran/easy_params) classes that mirror the form structure, providing type coercion, validation, and strong parameter handling for form submissions. Each element's `output` configuration determines how submitted data is processed

### Key Features

- **Declarative DSL**: Define forms with simple, readable syntax
- **Nested Forms**: Support for complex nested structures with `subform` and `many`
- **Custom Parameter Validation**: Use the `params` method to add custom validation logic and schema modifications
- **Dynamic Collections**: JavaScript-powered add/remove functionality for many relationships
- **Flexible Rendering**: Each element can be configured with custom input types, labels, and HTML attributes
- **Error Integration**: Built-in support for displaying validation errors
- **Rails Integration**: Seamless integration with Rails forms and parameter handling

### Data Flow

ActionForm follows a bidirectional data flow pattern that handles both form display and form submission:


#### **Phase 1: Form Display**
1. **Object/Model**: Your Ruby object (User model, ActiveRecord instance, or plain Ruby object) containing data to display
2. **Form Definition**: ActionForm class defined using the DSL (`element`, `subform`, `many` methods)
3. **Element Instances**: Each form element becomes an instance bound to the object, with access to current values, errors, and HTML attributes
4. **HTML Rendering**: Final HTML output rendered using Phlex, ready for the browser

#### **Phase 2: Form Submission**
1. **User Input**: Data submitted through the form by the user
2. **Parameter Validation**: ActionForm's auto-generated [EasyParams](https://github.com/andriy-baran/easy_params) classes validate and coerce submitted data
3. **Form Processing**: Your application logic processes the validated data (database saves, business logic, etc.)
4. **Response**: Result sent back to user (success page, error display, redirect, etc.)

#### **Key Benefits:**
- **Single Source of Truth**: The same form definition handles both displaying existing data and processing new data
- **Automatic Parameter Handling**: [EasyParams](https://github.com/andriy-baran/easy_params) classes are automatically generated to mirror your form structure
- **Custom Parameter Validation**: Use the `params` method to add custom validation logic and schema modifications
- **Error Integration**: Failed validations can re-render the form with submitted data and error messages
- **Nested Support**: Both phases support complex nested structures through `subform` and `many` relationships

## Usage

ActionForm follows a **Declare/Plan/Execute** pattern that separates form definition from data handling and rendering:

1. **Declare**: Define your form structure using the DSL (`element`, `subform`, `many`)
2. **Plan**: ActionForm creates element instances bound to your object's actual values
3. **Execute**: Each element renders itself with the appropriate HTML, labels, and validation

### Form elements declaration

ActionForm provides a declarative DSL for defining form elements. Each form class inherits from `ActionForm::Base` and uses three main methods to define form structure:

#### **Basic Elements**

Use `element` to define individual form fields:

```ruby
class UserForm < ActionForm::Base
  element :name do
    input type: :text, class: "form-control"
    output type: :string, presence: true
    label text: "Full Name", class: "form-label"
  end

  element :email do
    input type: :email, placeholder: "user@example.com"
    output type: :string, presence: true, format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  end

  element :age do
    input type: :number, min: 0, max: 120
    output type: :integer, presence: true
  end
end
```

#### **Available Input Types**

- **HTML input types**: `:text`, `:email`, `:password`, `:number`, `:tel`, `:url`, etc.
- **Selection inputs**: `:select`
- **Other inputs**: `:textarea`, `:hidden`

#### **Available Output Types**

ActionForm uses [EasyParams](https://github.com/andriy-baran/easy_params) for parameter validation and type coercion:

- **Basic types**: `:string`, `:integer`, `:float`, `:bool`, `:date`, `:datetime`
- **Collections**: `:array` (with `of:` option for element type)
- **Validation options**: `presence: true`, `format: regex`, `inclusion: { in: [...] }`

#### **Element Configuration Methods**

```ruby
element :field_name do
  # Input configuration
  input type: :text, class: "form-control", placeholder: "Enter value"

  # Output/validation configuration
  output type: :string, presence: true, format: /\A\d+\z/

  # Label configuration
  label text: "Custom Label", class: "form-label"

  # Select options (for select, radio, checkbox)
  options [["value1", "Label 1"], ["value2", "Label 2"]]

  # Elements tagging
  tags column: "1"
end
```

#### **Nested Forms**

Use `subform` for single nested objects:

```ruby
class UserForm < ActionForm::Base
  subform :profile do
    element :bio do
      input type: :textarea, rows: 4
      output type: :string
    end

    element :avatar do
      input type: :file
      output type: :string
    end
  end
end
```

Use `many` for collections of nested objects. Note that `many` requires a `subform` block inside it:

```ruby
class UserForm < ActionForm::Base
  many :addresses do
    subform do
      element :street do
        input type: :text
        output type: :string, presence: true
      end

      element :city do
        input type: :text
        output type: :string, presence: true
      end
    end
  end
end
```

#### **Complete Example**

```ruby
class UserForm < ActionForm::Base
  element :name do
    input type: :text, class: "form-control"
    output type: :string, presence: true
    label text: "Full Name"
  end

  element :email do
    input type: :email, class: "form-control"
    output type: :string, presence: true
  end

  element :role do
    input type: :select, class: "form-control"
    output type: :string, presence: true
    options [["admin", "Administrator"], ["user", "User"]]
  end

  element :interests do
    input type: :checkbox
    output type: :array, of: :string
    options [["tech", "Technology"], ["sports", "Sports"], ["music", "Music"]]
  end

  subform :profile do
    element :bio do
      input type: :textarea, rows: 4
      output type: :string
    end
  end

  many :addresses do
    subform do
      element :street do
        input type: :text
        output type: :string, presence: true
      end

      element :city do
        input type: :text
        output type: :string, presence: true
      end
    end
  end
end
```

### Custom Parameter Validation

ActionForm provides a `params` method that allows you to add custom validation logic and schema modifications to your form's parameter handling. This is particularly useful for complex validation rules that depend on context or require cross-field validation.

#### **Basic Usage**

Use the `params` method to define custom validation logic:

```ruby
class UserForm < ActionForm::Base
  element :email do
    input type: :email
    output type: :string, presence: true
  end

  element :password do
    input type: :password
    output type: :string
  end

  element :password_confirmation do
    input type: :password
    output type: :string
  end

  # Custom parameter validation
  params do
    validates :password, presence: true
    validates :password_confirmation, presence: true
    validates :password, confirmation: true
  end
end
```

#### **Conditional Validation**

You can add conditional validation logic based on context:

```ruby
class UserForm < ActionForm::Base
  element :email do
    input type: :email
    output type: :string, presence: true
  end

  element :password do
    input type: :password
    output type: :string
  end

  # Conditional validation based on external context
  params do
    secure_mode = true  # This could come from configuration or request context

    validates :password, presence: true, if: -> { secure_mode }
    validates :password, length: { minimum: 8 }, if: -> { secure_mode }
  end
end
```

#### **Nested Form Validation**

The `params` method also supports validation for nested forms using schema blocks:

```ruby
class UserForm < ActionForm::Base
  element :email do
    input type: :email
    output type: :string, presence: true
  end

  subform :profile, default: {} do
    element :name do
      input type: :text
      output type: :string
    end
  end

  many :addresses, default: [{}] do
    subform do
      element :street do
        input type: :text
        output type: :string
      end

      element :city do
        input type: :text
        output type: :string
      end
    end
  end

  params do
    # Validate nested subform
    profile_attributes_schema do
      validates :name, presence: true
    end

    # Validate nested collection
    addresses_attributes_schema do
      validates :street, presence: true
      validates :city, presence: true
    end
  end
end
```

#### **Dynamic Form Classes**

You can create dynamic form classes with different validation rules:

```ruby
class BaseUserForm < ActionForm::Base
  element :email do
    input type: :email
    output type: :string, presence: true
  end

  element :password do
    input type: :password
    output type: :string
  end
end

# Create a secure version with additional validation
SecureUserForm = Class.new(BaseUserForm)
SecureUserForm.params do
  validates :password, presence: true, length: { minimum: 8 }
  validates :password, format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/ }
end

# Create a basic version with minimal validation
BasicUserForm = Class.new(BaseUserForm)
BasicUserForm.params do
  validates :password, presence: true
end
```

#### **Integration with Controllers**

The custom parameter validation integrates seamlessly with your controllers:

```ruby
class UsersController < ApplicationController
  def create
    user_params = UserForm.params_definition.new(params)

    if user_params.valid?
      @user = User.create!(user_params.to_h)
      redirect_to @user
    else
      @form = @form.with_params(user_params)
      render :new
    end
  end
end
```

The `params` method provides a powerful way to extend ActionForm's parameter handling with custom validation logic while maintaining the declarative nature of form definition.

### Modifying Element Definitions

ActionForm allows you to modify existing element, subform, and `many` definitions after they have been declared. This feature enables you to extend or customize form definitions without altering the original class structure, making it perfect for conditional modifications, inheritance patterns, and dynamic form customization.

#### **Modifying Elements**

Use the `{element_name}_element` method to modify an existing element definition:

```ruby
class UserForm < ActionForm::Base
  element :email do
    input type: :email
    output type: :string
  end

  element :password do
    input type: :password
    output type: :string
  end
end

# Modify existing element definitions
UserForm.email_element do
  output type: :string, presence: true, format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
end

UserForm.password_element do
  output type: :string, presence: true, length: { minimum: 8 }
end
```

#### **Modifying Subforms**

Use the `{subform_name}_subform` method to modify an existing subform definition:

```ruby
class UserForm < ActionForm::Base
  subform :profile do
    element :bio do
      input type: :textarea
      output type: :string
    end
  end
end

# Modify the subform to add validation or change defaults
UserForm.profile_subform default: {} do
  bio_element do
    output type: :string, presence: true
  end

  # You can also add new elements
  element :avatar do
    input type: :file
    output type: :string
  end
end
```

#### **Modifying Many Relationships**

Use the `{many_name}_subforms` method to modify an existing `many` definition:

```ruby
class OrderForm < ActionForm::Base
  many :items do
    subform do
      element :name do
        input type: :text
        output type: :string
      end

      element :quantity do
        input type: :number
        output type: :integer
      end
    end
  end
end

# Modify the many relationship to add validation or change defaults
OrderForm.items_subforms default: [{}] do
  subform do
    name_element do
      output type: :string, presence: true
    end

    quantity_element do
      output type: :integer, presence: true, inclusion: { in: 1..100 }
    end

    # Add new elements to existing many subforms
    element :price do
      input type: :number
      output type: :float, presence: true
    end
  end
end
```

#### **Inheritance and Modifications**

Element modifications work seamlessly with class inheritance:

```ruby
class BaseForm < ActionForm::Base
  element :name do
    input type: :text
    output type: :string
  end
end

class UserForm < BaseForm
  element :email do
    input type: :email
    output type: :string
  end
end

# Modify inherited elements
UserForm.name_element do
  output type: :string, presence: true
end

# Modify elements defined in subclass
UserForm.email_element do
  output type: :string, presence: true
end
```

Here's a complete example showing element modifications in action:

```ruby
class OrderForm < ActionForm::Base
  element :name do
    input(type: :text)
    output(type: :string)
  end

  subform :customer do
    element :name do
      input(type: :text)
      output(type: :string)
    end
  end

  many :items do
    subform do
      element :name do
        input(type: :text)
        output(type: :string)
      end

      element :quantity do
        input(type: :number)
        output(type: :integer)
      end

      element :price do
        input(type: :number)
        output(type: :float)
      end
    end
  end
end

# Apply modifications to add validation
secure = true

OrderForm.name_element do
  output(type: :string, presence: true, if: -> { secure })
end

OrderForm.customer_subform default: {} do
  name_element do
    output(type: :string, presence: true, if: -> { secure })
  end
end

OrderForm.items_subforms default: [{}] do
  subform do
    name_element do
      output(type: :string, presence: true, if: -> { secure })
    end
    quantity_element do
      output(type: :integer, presence: true, if: -> { secure })
    end
    price_element do
      output(type: :float, presence: true, if: -> { secure })
    end
  end
end

# Now the form has validation enabled
params = OrderForm.params_definition.new({})
expect(params).to be_invalid
```

#### **Key Benefits**

- **Non-Destructive**: Modify form definitions without changing the original class
- **Conditional Logic**: Apply modifications based on runtime conditions
- **Inheritance Support**: Works seamlessly with class inheritance
- **Flexible Extension**: Add validation, change defaults, or add new elements to existing definitions
- **Reusability**: Create base forms and customize them for specific use cases

This feature provides a powerful way to customize and extend form definitions while maintaining the declarative nature of ActionForm.

### Composition and Owner Delegation

ActionForm includes a composition system that allows form components (elements, subforms, and `many` collections) to access methods from their owner (typically the parent form or a custom host object). This promotes code reuse and reduces redundancy by allowing shared logic to be defined in a central location and accessed by multiple form components.

#### **How Composition Works**

When you create a form, all nested elements and subforms automatically have access to their owner through the `owner` accessor. Methods called on elements or subforms that are not defined locally are automatically delegated up the ownership chain, allowing you to access methods from the parent form or a custom host object.

#### **Automatic Ownership Chain**

Ownership is automatically established when forms are built:

```ruby
class ProductForm < ActionForm::Base
  element :name do
    input(type: :text)
    output(type: :string)

    # This method can call methods on the owner (ProductForm)
    def render?
      name_render?  # Delegates to owner.name_render?
    end
  end

  many :variants, default: [{}] do
    subform do
      element :name do
        input(type: :text)
        output(type: :string)

        def render?
          variants_name_render?  # Delegates to owner.variants_name_render?
        end
      end

      def render?
        variants_subform_render?  # Delegates to owner.variants_subform_render?
      end
    end
  end

  subform :manufacturer, default: {} do
    element :name do
      input(type: :text)
      output(type: :string)

      def render?
        manufacturer_name_render?  # Delegates to owner.manufacturer_name_render?
      end
    end
  end

  # Methods accessible by nested components
  def name_render?
    true
  end

  def variants_name_render?
    true
  end

  def variants_subform_render?
    true
  end

  def manufacturer_name_render?
    true
  end
end
```

#### **Custom Host Object**

You can pass a custom host object when initializing a form, allowing you to separate form logic from business logic:

```ruby
class HostObject
  def name_render?
    current_user.admin? || form_context == :edit
  end

  def variants_subform_render?
    feature_enabled?(:variants)
  end

  def variants_name_render?
    true
  end

  def variants_price_render?
    pricing_enabled?
  end

  def manufacturer_name_render?
    manufacturer_feature_enabled?
  end
end

class ProductForm < ActionForm::Base
  element :name do
    input(type: :text)
    output(type: :string)

    def render?
      name_render?  # Calls HostObject#name_render?
    end
  end

  many :variants, default: [{}] do
    subform do
      element :name do
        input(type: :text)
        output(type: :string)

        def render?
          variants_name_render?  # Calls HostObject#variants_name_render?
        end
      end

      element :price do
        input(type: :number)
        output(type: :float)

        def render?
          variants_price_render?  # Calls HostObject#variants_price_render?
        end
      end

      def render?
        variants_subform_render?  # Calls HostObject#variants_subform_render?
      end
    end
  end

  subform :manufacturer, default: {} do
    element :name do
      input(type: :text)
      output(type: :string)

      def render?
        manufacturer_name_render?  # Calls HostObject#manufacturer_name_render?
      end
    end
  end
end

# Use the form with a custom host object
host = HostObject.new
product = Product.new(name: "Product 1")
form = ProductForm.new(object: product, owner: host)
```

#### **Ownership Chain Traversal**

The composition system supports multi-level ownership chains. When a method is called on an element or subform, it searches up the ownership chain until it finds the method:

```ruby
class GrandparentForm < ActionForm::Base
  def shared_helper
    "grandparent"
  end
end

class ParentForm < ActionForm::Base
  def shared_helper
    "parent"
  end
end

class ChildForm < ActionForm::Base
  element :field do
    input(type: :text)

    def render?
      shared_helper  # Will find ParentForm#shared_helper first
    end
  end
end

# If ChildForm has ParentForm as owner, and ParentForm has GrandparentForm as owner:
# The method lookup order is: ChildForm -> ParentForm -> GrandparentForm
```

#### **Accessing Owner Directly**

You can access the owner directly using the `owner` accessor:

```ruby
class ProductForm < ActionForm::Base
  element :discount_code do
    input(type: :text)
    output(type: :string)

    def disabled?
      # Access owner's methods directly
      owner.current_user && !owner.current_user.admin?
    end

    def placeholder
      owner.discount_placeholder_text
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id])
  end

  def discount_placeholder_text
    "Enter discount code"
  end
end
```

#### **Ownership Hierarchy**

The ownership hierarchy is automatically established as follows:

- **Top-level form**: Can have a custom `owner` passed during initialization
- **Elements**: Owner is the form or subform that contains them
- **Subforms**: Owner is the form that contains them
- **SubformsCollection (many)**: Owner is the form that contains them
- **Nested elements in subforms**: Owner is the subform that contains them
- **Nested subforms**: Owner is the parent form or subform

#### **Practical Use Cases**

**Conditional Rendering Based on Context:**
```ruby
class OrderForm < ActionForm::Base
  element :admin_notes do
    input(type: :textarea)
    output(type: :string)

    def render?
      owner.current_user&.admin?
    end
  end

  def current_user
    @current_user
  end
end
```

**Shared Validation Logic:**
```ruby
class RegistrationForm < ActionForm::Base
  element :email do
    input(type: :email)
    output(type: :string)

    def disabled?
      owner.email_locked?
    end
  end

  element :email_confirmation do
    input(type: :email)
    output(type: :string)

    def disabled?
      owner.email_locked?
    end
  end

  def email_locked?
    @user.persisted? && @user.email_verified?
  end
end
```

**Feature Flags:**
```ruby
class SettingsForm < ActionForm::Base
  many :advanced_settings do
    subform do
      element :feature_flag do
        input(type: :checkbox)
        output(type: :bool)

        def render?
          owner.feature_enabled?(:advanced_settings)
        end
      end
    end

    def render?
      owner.feature_enabled?(:advanced_settings)
    end
  end

  def feature_enabled?(feature)
    FeatureFlags.enabled?(feature, current_user)
  end
end
```

#### **Benefits**

- **Code Reuse**: Share common logic across multiple form components
- **Separation of Concerns**: Keep business logic in host objects, form logic in forms
- **Flexibility**: Support conditional rendering and behavior based on context
- **Maintainability**: Centralize shared logic instead of duplicating it
- **Testability**: Test host objects separately from form definitions

The composition system provides a powerful mechanism for creating flexible, maintainable forms that can adapt to different contexts and requirements.

### Tagging system

ActionForm includes a flexible tagging system that allows you to add custom metadata to form elements and control rendering behavior. Tags serve multiple purposes:

#### **Purpose of Tags**

1. **Rendering Control**: Tags control how elements are rendered (e.g., showing error messages, template rendering)
2. **Custom Metadata**: Store custom data that can be accessed during rendering
3. **Element Classification**: Mark elements with specific characteristics for conditional logic

#### **Automatic Tags**

ActionForm automatically adds several tags based on element configuration:

```ruby
element :email do
  input type: :email
  output type: :string
  options [["admin", "Admin"], ["user", "User"]]  # Adds options: true tag
end

# Automatic tags added:
# - input: :email (from input type)
# - output: :string (from output type)
# - options: true (from options method)
# - errors: true/false (based on validation errors)
```

#### **Custom Tags**

Add custom tags using the `tags` method:

```ruby
element :password do
  input type: :password
  output type: :string, presence: true

  # Custom tags
  tags row: "3",
       column: "4",
       background: "gray"
end
```

#### **Tag Usage in Rendering**

Tags are used throughout the rendering process:

```ruby
# Error display (automatic)
render_inline_errors(element) if element.tags[:errors]

# Custom rendering logic
def render_element(element)
  if element.tags[:row] == "3"
    div(class: "high-priority") { super }
  else
    super
  end
end
```

#### **Nested Form Tags**

Tags are automatically propagated in nested forms:

```ruby
many :addresses do
  subform do
    element :street do
      input type: :text
      tags required: true
    end
  end
end

# Each address element will have:
# - input: :text
# - subform: :addresses (added automatically)
# - required: true (from custom tag)
```

#### **Practical Examples**

**Conditional Styling:**
```ruby
element :email do
  input type: :email
  tags field_type: "contact"
end

# In your form class:
def render_input(element)
  super(class: css_class)
  span do
    help_info[element.tags[:field_type]]
  end
end
```

**Custom Error Handling:**
```ruby
element :username do
  input type: :text
  tags custom_validation: true
end

# Override error rendering:
def render_inline_errors(element)
  if element.tags[:custom_validation]
    div(class: "custom-errors") { element.errors_messages.join(" | ") }
  else
    super
  end
end
```

The tagging system provides a powerful way to extend ActionForm's behavior without modifying the core library, enabling custom rendering logic and element classification.


### Rendering process

ActionForm uses a hierarchical rendering system built on [Phlex](https://www.phlex.fun/) that allows complete customization of HTML output. The rendering process follows a clear flow from form-level down to individual elements.

#### **Rendering Flow**

```
view_template (main entry point)
    ↓
render_form (form wrapper)
    ↓
render_elements (iterate through all elements)
    ↓
render_element (individual element)
    ↓
render_label + render_input + render_inline_errors
```

#### **Core Rendering Methods**

**Form Level:**
- `view_template` - Main entry point, defines overall form structure
- `render_form` - Renders the `<form>` wrapper with attributes
- `render_elements` - Iterates through all form elements
- `render_submit` - Renders the submit button

**Element Level:**
- `render_element` - Renders a complete form element (label + input + errors)
- `render_label` - Renders the element's label
- `render_input` - Renders the input field
- `render_inline_errors` - Renders validation error messages

**Subform Level:**
- `render_subform` - Renders a single nested form
- `render_many_subforms` - Renders collections of nested forms with JavaScript
- `render_subform_template` - Renders templates for dynamic form addition

#### **Customizing Rendering**

You can override any rendering method in your form class to customize the HTML output:

**Basic Customization:**
```ruby
class UserForm < ActionForm::Base
  element :name do
    input type: :text
    output type: :string, presence: true
  end

  # Override element rendering to add custom wrapper
  def render_element(element)
    div(class: "form-group") do
      super
    end
  end

  # Customize label rendering
  def render_label(element)
    div(class: "label-wrapper") do
      super
    end
  end

  # Customize input rendering
  def render_input(element, **html_attributes)
    div(class: "input-wrapper") do
      super(class: "form-control")
    end
  end
end
```

**Bootstrap-Style Layout:**
```ruby
class UserForm < ActionForm::Base
  element :name do
    input type: :text
    output type: :string, presence: true
  end

  # Bootstrap grid layout
  def render_element(element)
    div(class: "row mb-3") do
      render_label(element)
      render_input(element)
      render_inline_errors(element) if element.tags[:errors]
    end
  end

  def render_label(element)
    div(class: "col-md-3") do
      super(class: "form-label")
    end
  end

  def render_input(element, **html_attributes)
    div(class: "col-md-9") do
      super(class: "form-control")
    end
  end
end
```

**Conditional Rendering:**
```ruby
class UserForm < ActionForm::Base
  element :email do
    input type: :email
    tags field_type: "contact"
  end

  element :password do
    input type: :password
    tags field_type: "security"
  end

  # Conditional rendering based on tags
  def render_element(element)
    case element.tags[:field_type]
    when "contact"
      div(class: "contact-field") { super }
    when "security"
      div(class: "security-field") { super }
    else
      super
    end
  end
end
```

**Custom Error Rendering:**
```ruby
class UserForm < ActionForm::Base
  element :username do
    input type: :text
    output type: :string, presence: true
  end

  # Custom error display
  def render_inline_errors(element)
    if element.tags[:errors]
      div(class: "alert alert-danger") do
        strong { "Error: " }
        element.errors_messages.join(", ")
      end
    end
  end
end
```

**Custom Submit Button:**
```ruby
class UserForm < ActionForm::Base
  # Custom submit button with styling
  def render_submit(**html_attributes)
    div(class: "form-actions") do
      super(class: "btn btn-primary", **html_attributes)
    end
  end
end
```

**Complete Form Layout Override:**
```ruby
class UserForm < ActionForm::Base
  element :name do
    input type: :text
    output type: :string, presence: true
  end

  # Override the entire form structure
  def view_template
    div(class: "custom-form") do
      h2 { "User Registration" }
      render_elements
      div(class: "form-footer") do
        render_submit
        a(href: "/cancel") { "Cancel" }
      end
    end
  end
end
```

#### **Advanced Customization**

**Custom Input Types:**
```ruby
class UserForm < ActionForm::Base
  element :rating do
    input type: :text
    tags custom_input: "rating"
  end

  # Custom input rendering for specific types
  def render_input(element, **html_attributes)
    if element.tags[:custom_input] == "rating"
      render_rating_input(element, **html_attributes)
    else
      super
    end
  end

  private

  def render_rating_input(element, **html_attributes)
    div(class: "rating-input") do
      5.times do |i|
        input(type: "radio",
              name: element.html_name,
              value: i + 1,
              checked: element.value == i + 1)
      end
    end
  end
end
```

**Dynamic Form Structure:**
```ruby
class UserForm < ActionForm::Base
  element :name do
    input type: :text
    tags section: "basic"
  end

  element :email do
    input type: :email
    tags section: "contact"
  end

  # Group elements by sections
  def render_elements
    sections = elements_instances.group_by { |el| el.tags[:section] }

    sections.each do |section_name, elements|
      div(class: "form-section", id: section_name) do
        h3 { section_name.to_s.capitalize }
        elements.each { |element| render_element(element) }
      end
    end
  end
end
```

The rendering system provides complete flexibility while maintaining the declarative nature of form definition. You can customize as little or as much as needed, from individual elements to the entire form structure.

### Element

The `ActionForm::Element` class represents individual form elements and provides methods to access their data, control rendering, and customize behavior. Each element is bound to an object and can access its current values, errors, and HTML attributes.

#### **Core Methods**

**`value`** - Gets the current value from the bound object
```ruby
element :name do
  input type: :text

  def value
    # Default: object.name
    object.other_name
  end
end
```
**`html_value`** - Formats value for HTML (dafault `value.to_s`):
```ruby
element :name do
  input type: :text

  def html_value
    value.strftime('%Y-%m-%d') # Format before render
  end
end
```

**`render?`** - Controls whether the element should be rendered:
```ruby
element :admin_field do
  input type: :text

  def render?
    object.admin?
  end
end

# Or conditionally render elements:
def render_elements
  elements_instances.select(&:render?).each do |element|
    render_element(element)
  end
end
```

**`detached?`** - Indicates if the element is detached from the object (uses static values):
```ruby
element :static_field do
  input type: :text, value: "Static Value"

  def detached?
    true  # This element doesn't bind to object values
  end
end
```



#### **Label Methods**

**`label_text`** - Gets the text to display in the label:
```ruby
element :full_name do
  input type: :text
  label text: "Complete Name", class: 'cool-label', id: 'full-name-label-id'
end
```

**`display: false`** - Label won't be rendered
```ruby
element :full_name do
  input type: :text
  label display: false
end
```

#### **Element Properties**

**`name`** - The element's name (symbol):
```ruby
element :username do
  input type: :text
end

# Access the name:
element.name  # => :username
```

**`tags`** - Access to element tags:
```ruby
element :priority_field do
  input type: :text
  tags priority: "high", section: "important"
end

element.tags[:priority]  # => "high"
element.tags[:section]   # => "important"
```

**`errors_messages`** - Validation error messages:
```ruby
element :email do
  input type: :email
  output type: :string, presence: true
end

# When validation fails:
element.errors_messages  # => ["can't be blank", "is invalid"]
```

**`disabled?`** - Controls whether the element is disabled:
```ruby
element :username do
  input type: :text

  def disabled?
    object.persisted?  # Disable for existing records
  end
end
```

**`readonly?`** - Controls whether the element is readonly:
```ruby
element :email do
  input type: :email

  def readonly?
    object.verified?  # Readonly if email is verified
  end
end
```

#### **Element Lifecycle**

Elements go through several phases:

1. **Definition** - Element class is created with DSL configuration
2. **Instantiation** - Element instance is created and bound to object
3. **Rendering** - Element is rendered to HTML (if `render?` returns true)
4. **Validation** - Element values are validated during form submission

```ruby
class UserForm < ActionForm::Base
  element :name do
    input type: :text
    output type: :string, presence: true
  end

  # Customize any phase:
  def render_element(element)
    if element.render?
      div(class: "form-group") do
        render_label(element)
        render_input(element)
        render_inline_errors(element) if element.tags[:errors]
      end
    end
  end
end
```

### Rails integration

ActionForm provides seamless integration with Rails through `ActionForm::Rails::Base`, which extends the core functionality with Rails-specific features like automatic model binding, nested attributes, and Rails form helpers.

#### **Rails Form Class**

Use `ActionForm::Rails::Base` instead of `ActionForm::Base` for Rails applications:

```ruby
class UserForm < ActionForm::Rails::Base
  resource_model User

  element :name do
    input type: :text
    output type: :string, presence: true
  end

  element :email do
    input type: :email
    output type: :string, presence: true
  end

  element :password do
    input type: :password
    output type: :string
  end

  element :password_confirmation do
    input type: :password
    output type: :string
  end

  # Custom parameter validation for Rails integration
  params do
    validates :password, presence: true, length: { minimum: 6 }
    validates :password, confirmation: true
  end
end
```

#### **Model Binding**

The `resource_model` method automatically configures the form for your Rails model:

```ruby
class UserForm < ActionForm::Rails::Base
  resource_model User  # Sets up automatic parameter scoping and model binding
end

# In your controller:
def new
  @form = UserForm.new(model: User.new)
end

def create
  @form = UserForm.new(model: User.new, params: params)
  if @form.class.params_definition.new(params).valid?
    # Process the form
  else
    render :new
  end
end
```

#### **Parameter Scoping**

ActionForm automatically handles Rails parameter scoping:

```ruby
class UserForm < ActionForm::Rails::Base
  resource_model User  # Automatically scopes to 'user' parameters
end

# Form parameters are automatically scoped to:
# params[:user][:name]
# params[:user][:email]
# etc.
```

You can also set custom scopes:

```ruby
class AdminUserForm < ActionForm::Rails::Base
  scope :admin_user  # Parameters will be scoped to params[:admin_user]
end
```

#### **Nested Attributes for many Relations**

Rails integration automatically handles nested attributes for `many` relationships:

```ruby
class UserForm < ActionForm::Rails::Base
  resource_model User

  element :name do
    input type: :text
    output type: :string, presence: true
  end

  many :addresses do
    subform do
      element :street do
        input type: :text
        output type: :string, presence: true
      end

      element :city do
        input type: :text
        output type: :string, presence: true
      end
    end
  end
end
```

**Automatic Features:**
- Primary key elements (`id`) are automatically added for existing records
- Delete elements (`_destroy`) are automatically added for removal
- Parameters are properly scoped with `_attributes` suffix
- JavaScript for dynamic add/remove functionality

**Generated Parameters:**
```ruby
# For addresses, parameters look like:
params[:user][:addresses_attributes] = {
  "0" => { "id" => "1", "street" => "123 Main St", "city" => "Anytown" },
  "1" => { "id" => "2", "street" => "456 Oak Ave", "city" => "Somewhere", "_destroy" => "1" }
}
```

#### **Controller Integration**

```ruby
class UsersController < ApplicationController
  def new
    @form = UserForm.new(model: User.new)
  end

  def create
    @form = UserForm.new(model: User.new, params: params)
    user_params = @form.class.params_definition.new(params)

    if user_params.valid?
      @user = User.create!(user_params.user.to_h)
      redirect_to @user
    else
      # Custom validation errors are automatically available
      @form = @form.with_params(user_params)
      render :new
    end
  end

  def edit
    @form = UserForm.new(model: @user)
  end

  def update
    @form = UserForm.new(model: @user, params: params)
    user_params = @form.class.params_definition.new(params)

    if user_params.valid?
      @user.update!(user_params.user.to_h)
      redirect_to @user
    else
      # Custom validation errors (like password confirmation) are displayed
      @form = @form.with_params(user_params)
      render :edit
    end
  end
end
```

#### **View Integration**

```erb
<!-- app/views/users/new.html.erb -->
<%= @form %>
```

#### **Error Handling**

ActionForm integrates with Rails validation errors:

```ruby
class UserForm < ActionForm::Rails::Base
  resource_model User

  element :email do
    input type: :email
    output type: :string, presence: true, format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  end
end

# When validation fails:
@form = @form.with_params(invalid_params)
# The form will automatically display validation errors
```

#### **Rails-Specific Features**

**Automatic Form Attributes:**
- CSRF protection with authenticity tokens
- UTF-8 encoding
- Proper HTTP methods (POST/PATCH)
- Rails form helpers integration

**Model Integration:**
- Automatic `persisted?` checks
- Model name and param key handling
- Polymorphic path generation

**Nested Attributes Support:**
- Automatic `_attributes` parameter scoping
- Primary key handling for existing records
- Delete flag handling for record removal

#### **Dynamic Form Buttons**

ActionForm provides built-in methods for rendering add/remove buttons for dynamic `many` forms:

**`render_new_subform_button`** - Renders a button to add new subform instances:

```ruby
class UserForm < ActionForm::Rails::Base
  resource_model User

  many :addresses do
    subform do
      element :street do
        input type: :text
        output type: :string, presence: true
      end

      element :city do
        input type: :text
        output type: :string, presence: true
      end
    end
  end

  # Custom rendering with add button
  def render_many_subforms(subforms)
    super  # Renders existing subforms and JavaScript

    # Add a button to create new subforms
    div(class: "form-actions") do
      render_new_subform_button(class: "btn btn-primary") do
        "Add Address"
      end
    end
  end
end
```

**`render_remove_subform_button`** - Renders a button to remove subform instances:

```ruby
class UserForm < ActionForm::Rails::Base
  resource_model User

  many :addresses do
    subform do
      element :street do
        input type: :text
        output type: :string, presence: true
      end

      element :city do
        input type: :text
        output type: :string, presence: true
      end
    end
  end

  # Custom subform rendering with remove button
  def render_subform(subform)
    div(class: "address-form") do
      super  # Render the subform elements

      # Add remove button for each subform
      div(class: "form-actions") do
        render_remove_subform_button(class: "btn btn-danger btn-sm") do
          "Remove Address"
        end
      end
    end
  end
end
```

**Complete Dynamic Form Example:**

```ruby
class UserForm < ActionForm::Rails::Base
  resource_model User

  many :addresses do
    element :street do
      input type: :text, class: "form-control"
      output type: :string, presence: true
    end

    element :city do
      input type: :text, class: "form-control"
      output type: :string, presence: true
    end

    element :zip_code do
      input type: :text, class: "form-control"
      output type: :string, presence: true
    end
  end

  # Custom rendering with both add and remove buttons
  def render_many_subforms(subforms)
    super
    # Add button to create new subforms
    div(class: "add-address-section") do
      render_new_subform_button(
        class: "btn btn-success",
        data: { insert_before_selector: ".add-address-section" }
      ) do
        span(class: "glyphicon glyphicon-plus") { }
        " Add Address"
      end
    end
  end

  private

  def render_subform(subform)
    div(class: "address-form border p-3 mb-3") do
      # Render subform elements
      super

      # Remove button
      div(class: "form-actions text-right") do
        render_remove_subform_button(
          class: "btn btn-outline-danger btn-sm"
        ) do
          span(class: "glyphicon glyphicon-trash") { }
          " Remove"
        end
      end
    end
  end
end
```

**Button Customization:**

Both methods accept HTML attributes and blocks for complete customization:

```ruby
# Custom styling and attributes
render_new_subform_button(
  class: "btn btn-primary btn-lg",
  id: "add-address-btn",
  data: {
    insert_before_selector: ".address-list",
    confirm: "Add a new address?"
  }
) do
  icon("plus") + " Add New Address"
end

render_remove_subform_button(
  class: "btn btn-danger btn-sm",
  data: {
    confirm: "Are you sure you want to remove this address?",
    method: "delete"
  }
) do
  icon("trash") + " Remove"
end
```

**JavaScript Integration:**

The buttons automatically integrate with ActionForm's JavaScript functions:
- `easyFormAddSubform(event)` - Adds new subform instances
- `easyFormRemoveSubform(event)` - Removes or marks subforms for deletion

The JavaScript handles:
- Template cloning with unique IDs
- Proper form field naming
- Delete flag setting for existing records
- DOM manipulation for dynamic forms

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/andriy-baran/action_form. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/andriy-baran/action_form/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActionForm project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/andriy-baran/action_form/blob/master/CODE_OF_CONDUCT.md).
