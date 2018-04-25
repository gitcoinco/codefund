defmodule CodeFundWeb.SponsorshipType do
  use CodeFundWeb.BaseType
  alias CodeFund.Schema.Property
  alias CodeFund.Schema.Sponsorship
  alias CodeFund.Schema.User
  import Ecto.Query

  def build_form(form) do
    form
    |> add(
      :campaign_id,
      :select,
      label: "Campaign",
      validation: [:required],
      choices: object_query_for_user("Campaign", form.opts |> Keyword.fetch!(:user))
    )
    |> property_field
    |> add(
      :creative_id,
      :select,
      label: "Creative",
      validation: [:required],
      choices: object_query_for_user("Creative", form.opts |> Keyword.fetch!(:user))
    )
    |> add(
      :bid_amount,
      :number_input,
      label: "CPC",
      validation: [:required],
      addon: "$",
      phoenix_opts: [
        step: "0.01",
        min: "0"
      ]
    )
    |> add(
      :redirect_url,
      :text_input,
      label: "URL",
      validation: [
        :required,
        format: [arg: ~r/^https?:\/\/.+$/]
      ]
    )
    |> add(
      :override_revenue_rate,
      form.opts |> Keyword.fetch!(:current_user) |> override_field_type(),
      label: form.opts |> Keyword.fetch!(:current_user) |> override_field_label(),
      validation: [:required],
      phoenix_opts: [
        value: set_override_revenue_rate_default(form.struct),
        step: "0.001",
        min: "0"
      ]
    )
    |> add(
      :save,
      :submit,
      label: "Submit",
      phoenix_opts: [
        class: "btn-primary"
      ]
    )
  end

  defp property_field(form) do
    case form.opts |> Keyword.fetch(:property) do
      :error ->
        form |> add(:property_id, SelectAssoc, label: "Property", validation: [:required])

      {:ok, %Property{id: property_id}} ->
        form
        |> add(
          :property_id,
          :hidden_input,
          label: "",
          phoenix_opts: [
            value: property_id
          ]
        )
    end
  end

  defp object_query_for_user(type, %User{id: id}) do
    from(o in Module.concat([CodeFund, Schema, type]), where: o.user_id == ^id)
    |> CodeFund.Repo.all()
    |> Enum.map(fn object -> {object.name, object.id} end)
  end

  defp override_field_type(user) do
    case CodeFund.Users.has_role?(user.roles, ["admin"]) do
      true -> :number_input
      false -> :hidden_input
    end
  end

  defp override_field_label(user) do
    case CodeFund.Users.has_role?(user.roles, ["admin"]) do
      true -> "Revenue Rate (override)"
      false -> ""
    end
  end

  defp set_override_revenue_rate_default(%Sponsorship{
         override_revenue_rate: override_revenue_rate
       })
       when not is_nil(override_revenue_rate),
       do: override_revenue_rate

  defp set_override_revenue_rate_default(%Sponsorship{user: %User{revenue_rate: revenue_rate}})
       when not is_nil(revenue_rate),
       do: revenue_rate

  defp set_override_revenue_rate_default(_), do: 0.5
end
