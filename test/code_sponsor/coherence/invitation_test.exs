defmodule CodeSponsor.Coherence.InvitationTest do
  use CodeSponsor.DataCase

  alias CodeSponsor.Coherence.Invitation

  @valid_attrs %{name: "Zacck", email: "zacck@me.com"}
  @invalid_attrs %{}

  describe "invitation changeset" do
    test "with valid attributes" do
      changeset = Invitation.changeset(%Invitation{}, @valid_attrs)
      assert changeset.valid?
    end

    test "new changeset valid attributes" do
      changeset = Invitation.new_changeset(@valid_attrs)
      assert changeset.valid?
    end

    test " errors out with invalid attributes" do
      changeset = Invitation.changeset(%Invitation{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

end
