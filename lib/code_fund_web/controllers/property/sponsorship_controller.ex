defmodule CodeFundWeb.Property.SponsorshipController do
  use CodeFundWeb, :controller
  alias CodeFundWeb.SponsorshipType
  alias CodeFund.Properties
  alias CodeFund.Schema.Property
  alias CodeFund.Schema.Sponsorship
  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin", "sponsor"])

  def new(conn, %{"property_id" => property_id}) do
    property = %Property{} = Properties.get_property!(property_id)

    form =
      create_form(
        SponsorshipType,
        %Sponsorship{},
        %{},
        property: property,
        user: conn.assigns.current_user,
        current_user: conn.assigns.current_user
      )

    render(conn, "new.html", form: form, property: property)
  end
end
