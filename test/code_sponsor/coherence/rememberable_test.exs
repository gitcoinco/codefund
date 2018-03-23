defmodule CodeSponsor.Coherence.RememberableTest do
  use CodeSponsor.DataCase

  alias CodeSponsor.Coherence.Rememberable

  @valid_attrs %{series_hash: "123", token_hash: "56vign", token_created_at: "2018-03-20 05:11:58Z", user_id: "1232"}
  @invalid_attrs %{}
  describe "Rememberable Schema" do
    test "creates a valid changeset" do
      changeset = Rememberable.new_changeset(@valid_attrs)
      assert changeset.valid?
    end

    test "invalid when changeset" do
      changeset = Rememberable.new_changeset(@invalid_attrs)
      refute changeset.valid?
    end
  end
end
