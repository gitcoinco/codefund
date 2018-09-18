defmodule CodeFund.Schema.UserTest do
  use CodeFund.DataCase
  alias CodeFund.Schema.User
  import Ecto.Changeset
  import CodeFund.Factory

  describe "users" do
    setup do
      valid_attrs =
        build(:user)
        |> Map.from_struct()
        |> Map.delete(:password_hash)
        |> Map.put(:password, "P@ssw0rd")
        |> Map.put(:password_confirmation, "P@ssw0rd")

      {:ok, %{valid_attrs: valid_attrs}}
    end

    test "changeset with valid attributes", %{valid_attrs: valid_attrs} do
      valid_attrs = valid_attrs
      assert User.changeset(%User{}, valid_attrs).valid?
    end

    test "changeset with missing required attributes", %{valid_attrs: valid_attrs} do
      required_fields = User.required()
      SharedExample.ModelTests.required_attribute_test(User, required_fields, valid_attrs)
    end

    test "it sets an api key when the api access is changed to true", %{valid_attrs: valid_attrs} do
      user = insert(:user)

      refute User.changeset(user, %{first_name: "test name"})
             |> get_field(:api_key)

      assert User.changeset(user, %{first_name: "test name", api_access: true})
             |> get_change(:api_key)

      refute User.changeset(%User{}, valid_attrs)
             |> get_field(:api_key)

      valid_attrs =
        valid_attrs
        |> Map.put(:api_access, true)

      assert User.changeset(%User{}, valid_attrs)
             |> get_change(:api_key)
    end
  end
end
