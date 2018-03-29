defmodule CodeFundWeb.Formex.Bootstrap do
  use Formex.Template, :helper

  @moduledoc false

  defmacro __using__([]) do
    quote do
      use Formex.Template, :helper
      import CodeFundWeb.Formex.Bootstrap

      @spec generate_input(form :: Form.t(), field :: Field.t()) :: Phoenix.HTML.safe()
      def generate_input(form, %Field{} = field) do
        type = field.type
        data = field.data
        phoenix_opts = field.phoenix_opts

        multi_input_args =
          if Enum.member?([:select, :multiple_select], type) do
            [data[:choices]]
          else
            []
          end

        file_input_args =
          if Enum.member?([:checkbox, :file_input], type) do
            [phoenix_opts]
          else
            [add_class(phoenix_opts, "form-control")]
          end

        args = [form.phoenix_form, field.name] ++ multi_input_args ++ file_input_args

        input = render_phoenix_input(field, args)

        if Enum.member?([:checkbox], type) do
          content_tag(
            :div,
            [
              content_tag(:label, [
                input
              ])
            ],
            class: "checkbox"
          )
        else
          input
        end
      end

      @spec generate_input(_form :: Form.t(), button :: Button.t()) :: Phoenix.HTML.safe()
      def generate_input(_form, %Button{} = button) do
        class =
          if String.match?(button.phoenix_opts[:class], ~r/btn\-/) do
            "btn"
          else
            "btn btn-default"
          end

        phoenix_opts = add_class(button.phoenix_opts, class)

        render_phoenix_input(button, [button.label, phoenix_opts])
      end

      @spec generate_label(form :: Form.t(), field :: Field.t(), class :: String.t()) ::
              Phoenix.HTML.safe()
      def generate_label(form, field, class \\ "") do
        Phoenix.HTML.Form.label(
          form.phoenix_form,
          field.name,
          field.label,
          class: "control-label " <> class
        )
      end
    end
  end

  def attach_addon(field_html, field) do
    if field.opts[:addon] do
      addon = content_tag(:span, field.opts[:addon], class: "input-group-text")
      addon_wrapper = content_tag(:div, [addon], class: "input-group-prepend")
      content_tag(:div, [addon_wrapper, field_html], class: "input-group")
    else
      field_html
    end
  end

  def attach_error(tags, form, field) do
    if has_error(form, field) do
      error_html =
        form
        |> get_errors(field)
        |> Enum.map(fn error ->
          content_tag(:span, format_error(error))
        end)

      error_field = content_tag(:div, error_html, class: "invalid-feedback")
      tags ++ [error_field]
    else
      tags
    end
  end

  def attach_error_class(wrapper_class, form, field) do
    if has_error(form, field) do
      wrapper_class ++ ["is-invalid"]
    else
      wrapper_class
    end
  end

  def attach_required_class(wrapper_class, field) do
    if field.required do
      wrapper_class ++ ["required"]
    else
      wrapper_class
    end
  end
end
