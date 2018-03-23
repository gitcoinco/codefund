defmodule CodeSponsor.Coherence.SchemasTest do
  use CodeSponsor.DataCase

  alias CodeSponsor.Coherence.{Schemas}
  alias CodeSponsor.Schema.User

  @email "zacck@me.com"
  @valid_user %{first_name: "Zacck", last_name: "Osiemo", email: @email, password: "jbjdbwqjbd--"}
  describe "Coherence Schemas" do
    test "list_user/0 lists all users" do
      insert_pair(:user)
      assert Repo.aggregate(User, :count, :id) == 2
      users = Schemas.list_user()
      assert Enum.count(users) == 2
    end

    test "get_by_user/1 lists a user" do
      user = insert(:user)
      fetched_user = Schemas.get_by_user([email: user.email])
      assert  user.id == fetched_user.id
    end

    test "get_user/1 gets a user" do
      user = insert(:user)
      fetched_user = Schemas.get_user(user.id)
      assert fetched_user.email == user.email
      assert fetched_user.first_name == user.first_name
      assert fetched_user.last_name == user.last_name
    end

    test "get_user/1! gets a user" do
      user = insert(:user)
      fetched_user = Schemas.get_user!(user.id)
      assert fetched_user.email == user.email
      assert fetched_user.first_name == user.first_name
      assert fetched_user.last_name == user.last_name
    end

    test "get_user/1! raises when no user" do
      assert_raise Ecto.NoResultsError, fn ->
        Schemas.get_user!("31c15cd2-1a1b-44c8-a893-b91bd0ad7385")
      end
    end

    test "get_user_by_email/1 finds a user" do
      user = insert(:user)
      assert Repo.aggregate(User, :count, :id) == 1
      email_user = Schemas.get_user_by_email(user.email)
      assert email_user.id == user.id
    end

    test "change_user/2 returns a changeset" do
      user = insert(:user)
      new_user =  Schemas.change_user(user, %{email: "zacck@mail.com"})
      assert new_user.changes.email == "zacck@mail.com"
    end

    test "change_user/1 returns a changeset" do
      new_user =  Schemas.change_user(%{email: "zacck@mail.com"})
      assert new_user.changes.email == "zacck@mail.com"
    end

    test "update_user/1 persists an update" do
      user = insert(:user)
      refute user.email == @email
      Schemas.update_user(user, %{email: @email})
      assert Repo.aggregate(User, :count, :id) == 1
      updated_user = Repo.one(User)
      assert updated_user.email == @email
    end

    test "create_user/1 creates a new user" do
      assert Repo.aggregate(User, :count, :id) == 0
      Schemas.create_user(@valid_user)
      assert Repo.aggregate(User, :count, :id) == 1
      user = Repo.one(User)
      assert user.email == @valid_user.email
      assert user.first_name == @valid_user.first_name
      assert user.last_name == @valid_user.last_name
    end
  end
end
