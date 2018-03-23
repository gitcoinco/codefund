defmodule CodeSponsor.Schema.InvitationTest do
  use CodeSponsor.DataCase

  alias CodeSponsor.Schema.Invitation

  @valid_attrs %{name: "Zacck", email: "zacck@me.co"}
  @invalid_attrs  %{}
  describe "invitation changeset" do
    test "when valid" do
      changeset = Invitation.new_changeset(@valid_attrs)
      assert changeset.valid?
    end

    test "when invalid" do
      changeset = Invitation.new_changeset(@invalid_attrs)
      refute changeset.valid?
    end
  end
end
