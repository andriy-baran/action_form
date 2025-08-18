module EasyForm
  module Inputs
    def text_field(attribute_name, name: nil, id: nil, **html_attributes)
      attribute = attribute_name.to_s
      input_name = name || attribute
      input_id = id || attribute

      Inputs::Text.call(
        name: input_name,
        id: input_id,
        input_attrs: html_attributes
      )
    end

    def checkbox(attribute_name,
                 name: nil,
                 id: nil,
                 value: "1",
                 unchecked_value: "0",
                 autocomplete: "off",
                 checked: false,
                 **html_attributes)
      attribute = attribute_name.to_s
      input_name = name || attribute
      input_id = id || attribute

      Inputs::Checkbox.call(
        name: input_name,
        id: input_id,
        value: value,
        unchecked_value: unchecked_value,
        checked: checked,
        autocomplete: autocomplete,
        input_attrs: html_attributes
      )
    end

    def radio_button(attribute_name,
                     value,
                     name: nil,
                     id: nil,
                     checked: false,
                     **html_attributes)
      attribute = attribute_name.to_s
      input_name = name || attribute
      input_id = id || "#{attribute}_#{value}"

      Inputs::Radio.call(
        name: input_name,
        value: value,
        id: input_id,
        checked: checked,
        input_attrs: html_attributes
      )
    end

    # def label(attribute_name, text = nil, for: nil, **html_attributes)
    #   attribute = attribute_name.to_s
    #   label_for = binding.local_variable_get(:for) || attribute
    #   label_text = text || humanize(attribute)

    #   Inputs::Label.call(
    #     text: label_text,
    #     for: label_for,
    #     label_attrs: html_attributes
    #   )
    # end

    def password_field(attribute_name, name: nil, id: nil, **html_attributes)
      attribute = attribute_name.to_s
      input_name = name || attribute
      input_id = id || attribute

      Inputs::Password.call(name: input_name, id: input_id, input_attrs: html_attributes)
    end

    def email_field(attribute_name, name: nil, id: nil, **html_attributes)
      attribute = attribute_name.to_s
      input_name = name || attribute
      input_id = id || attribute

      Inputs::Email.call(name: input_name, id: input_id, input_attrs: html_attributes)
    end

    def telephone_field(attribute_name, name: nil, id: nil, **html_attributes)
      attribute = attribute_name.to_s
      input_name = name || attribute
      input_id = id || attribute

      Inputs::Telephone.call(name: input_name, id: input_id, input_attrs: html_attributes)
    end

    def url_field(attribute_name, name: nil, id: nil, **html_attributes)
      attribute = attribute_name.to_s
      input_name = name || attribute
      input_id = id || attribute

      Inputs::Url.call(name: input_name, id: input_id, input_attrs: html_attributes)
    end

    def textarea(attribute_name, size: nil, name: nil, id: nil, **html_attributes)
      attribute = attribute_name.to_s
      input_name = name || attribute
      input_id = id || attribute

      cols, rows = nil
      if size
        # Accept "70x5" style
        parts = size.to_s.split("x", 2)
        cols = parts[0]
        rows = parts[1]
      end

      Inputs::Textarea.call(
        name: input_name,
        id: input_id,
        cols: cols,
        rows: rows,
        textarea_attrs: html_attributes
      )
    end

    def hidden_field(attribute_name, value: nil, name: nil, id: nil, autocomplete: "off", **html_attributes)
      attribute = attribute_name.to_s
      input_name = name || attribute
      input_id = id || attribute

      Inputs::Hidden.call(
        name: input_name,
        id: input_id,
        value: value,
        autocomplete: autocomplete,
        input_attrs: html_attributes
      )
    end

    def number_field(attribute_name, in: nil, step: nil, name: nil, id: nil, **html_attributes)
      attribute = attribute_name.to_s
      input_name = name || attribute
      input_id = id || attribute

      range = binding.local_variable_get(:in)
      min = range&.begin
      max = range&.end
      # Preserve float formatting like 1.0
      min = min.is_a?(Float) ? min.to_s : min
      max = max.is_a?(Float) ? max.to_s : max

      Inputs::Number.call(
        name: input_name,
        id: input_id,
        min: min,
        max: max,
        step: step,
        input_attrs: html_attributes
      )
    end

    def range_field(attribute_name, in: nil, name: nil, id: nil, **html_attributes)
      attribute = attribute_name.to_s
      input_name = name || attribute
      input_id = id || attribute

      range = binding.local_variable_get(:in)
      min = range&.begin
      max = range&.end

      Inputs::Range.call(
        name: input_name,
        id: input_id,
        min: min,
        max: max,
        input_attrs: html_attributes
      )
    end

    def search_field(attribute_name, name: nil, id: nil, **html_attributes)
      attribute = attribute_name.to_s
      input_name = name || attribute
      input_id = id || attribute

      Inputs::Search.call(name: input_name, id: input_id, input_attrs: html_attributes)
    end

    def color_field(attribute_name, value: "#000000", name: nil, id: nil, **html_attributes)
      attribute = attribute_name.to_s
      input_name = name || attribute
      input_id = id || attribute

      Inputs::Color.call(name: input_name, id: input_id, value: value, input_attrs: html_attributes)
    end

    def date_field(attribute_name, name: nil, id: nil, **html_attributes)
      attribute = attribute_name.to_s
      input_name = name || attribute
      input_id = id || attribute

      Inputs::Date.call(name: input_name, id: input_id, input_attrs: html_attributes)
    end

    def time_field(attribute_name, name: nil, id: nil, **html_attributes)
      attribute = attribute_name.to_s
      input_name = name || attribute
      input_id = id || attribute

      Inputs::Time.call(name: input_name, id: input_id, input_attrs: html_attributes)
    end

    def datetime_local_field(attribute_name, name: nil, id: nil, **html_attributes)
      attribute = attribute_name.to_s
      input_name = name || attribute
      input_id = id || attribute

      Inputs::DatetimeLocal.call(name: input_name, id: input_id, input_attrs: html_attributes)
    end

    def month_field(attribute_name, name: nil, id: nil, **html_attributes)
      attribute = attribute_name.to_s
      input_name = name || attribute
      input_id = id || attribute

      Inputs::Month.call(name: input_name, id: input_id, input_attrs: html_attributes)
    end

    def week_field(attribute_name, name: nil, id: nil, **html_attributes)
      attribute = attribute_name.to_s
      input_name = name || attribute
      input_id = id || attribute

      Inputs::Week.call(name: input_name, id: input_id, input_attrs: html_attributes)
    end

    private

    def humanize(str)
      str.to_s.tr("_", " ").split.map(&:capitalize).join(" ")
    end
  end
end
