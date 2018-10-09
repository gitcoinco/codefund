defmodule Framework.Phoenix.Form.Helpers do
  use Phoenix.HTML
  import CodeFundWeb.{HintHelpers, ErrorHelpers}

  @spec render_fields(list, Phoenix.HTML.Form.t()) :: list
  def render_fields(fields, form) do
    html =
      Enum.map(fields, fn field ->
        render_field(field, form)
      end)

    [html, content_tag(:button, "Submit", class: "btn btn-primary")]
  end

  @spec repo_objects_to_options(list, list, String.t()) :: Keyword.t()
  def repo_objects_to_options(objects, fields \\ [:name], delimiter \\ " - ") do
    Enum.map(objects, fn object ->
      field_name =
        Enum.map(fields, fn field_name ->
          cond do
            is_atom(field_name) ->
              Map.get(object, field_name)

            is_tuple(field_name) ->
              fields =
                field_name
                |> Tuple.to_list()
                |> Enum.map(&Access.key(&1))

              get_in(object, fields)
          end
        end)
        |> Enum.join(delimiter)

      {field_name, object.id}
    end)
  end

  @spec rest_method(atom) :: atom
  def rest_method(:update), do: :patch
  def rest_method(:create), do: :post

  @spec input_group(Phoenix.HTML.safe(), String.t(), Phoenix.HTML.safe(), String.t()) ::
          Phoenix.HTML.safe()
  defp input_group(field_html, label, hint_tag, error_tag, col_class \\ "col-sm-10") do
    content_tag(
      :div,
      [
        content_tag(:label, label, class: "control-label col-sm-2"),
        content_tag(
          :div,
          [
            content_tag(:div, field_html, class: "input-group"),
            hint_tag,
            error_tag
          ],
          class: col_class
        )
      ],
      class: "form-group row"
    )
  end

  defp checkbox_input_group(
         field_html,
         label,
         hint,
         col_class \\ "col-sm-10 form-group form-check pl-4"
       ) do
    content_tag(
      :div,
      [
        content_tag(:label, label, class: "control-label col-sm-2"),
        content_tag(
          :div,
          [
            field_html,
            content_tag(:label, hint, class: "form-check-label")
          ],
          class: col_class
        )
      ],
      class: "row"
    )
  end

  @spec addon_input(Phoenix.HTML.Form.t(), atom, String.t(), Keyword.t()) :: Phoenix.HTML.safe()
  defp addon_input(
         form,
         attribute,
         symbol,
         opts
       ) do
    field = number_input(form, attribute, opts)
    symbol_div = content_tag(:div, symbol, class: "input-currency")
    content_tag(:div, [symbol_div, field])
  end

  @spec render_field({atom, Keyword.t()}, Phoenix.HTML.Form.t()) :: Phoenix.HTML.safe()
  defp render_field({field_name, [type: type, label: label, opts: opts]}, form) do
    field_html =
      case type do
        :checkbox ->
          checkbox(
            form,
            field_name,
            Keyword.put(opts, :class, "#{opts[:class]} form-check-input")
          )

        :select ->
          select_fields(
            form,
            field_name,
            opts |> Keyword.put(:class, "#{opts[:class]} form-control selectize"),
            type
          )

        :multiple_select ->
          select_fields(
            form,
            field_name,
            opts |> Keyword.put(:class, "#{opts[:class]} form-control selectize"),
            type
          )

        :currency_input ->
          addon_input(
            form,
            field_name,
            "$",
            Keyword.put(opts, :class, "#{opts[:class]} form-control")
          )

        :percentage_input ->
          addon_input(
            form,
            field_name,
            "%",
            Keyword.put(opts, :class, "#{opts[:class]} form-control")
          )

        :image_preview ->
          image_preview(opts[:src])

        _other ->
          apply(Phoenix.HTML.Form, type, [
            form,
            field_name,
            Keyword.put(opts, :class, "#{opts[:class]} form-control")
          ])
      end

    render_input_group({field_name, field_html, [type: type, label: label, opts: opts]}, form)
  end

  defp render_field({field_name, args_list}, form) do
    render_field({field_name, Keyword.merge(args_list, opts: [])}, form)
  end

  defp render_input_group(
         {field_name, field_html, [type: :checkbox, label: label, opts: opts]},
         form
       ) do
    field_html
    |> checkbox_input_group(
      label,
      opts[:hint]
    )
  end

  defp render_input_group({field_name, field_html, [type: type, label: label, opts: opts]}, form) do
    field_html
    |> input_group(
      label,
      hint_tag(opts[:hint]),
      error_tag(form.source.assigns |> Map.get(:changeset), field_name)
    )
  end

  defp image_preview(nil), do: nil
  defp image_preview(image_url), do: img_tag(image_url)

  @spec select_fields(Phoenix.HTML.Form.t(), atom, Keyword.t(), atom) :: String.t()
  defp select_fields(form, field_name, opts, type) do
    {choices, opts} = Keyword.pop(opts, :choices)
    apply(Phoenix.HTML.Form, type, [form, field_name, choices, opts])
  end
end
