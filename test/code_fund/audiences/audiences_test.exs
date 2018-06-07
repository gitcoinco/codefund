defmodule CodeFund.AudiencesTest do
  use CodeFund.DataCase
  alias CodeFund.Audiences
  alias CodeFund.Schema.Audience
  import CodeFund.Factory

  describe "audiences" do
    @valid_attrs %{
      name: "Audience Test",
      programming_languages: ["ruby"]
    }
    @invalid_attrs %{
      name: "",
      programming_languages: ["ruby"]
    }

    @update_attrs %{
      name: "New Name",
      programming_languages: ["ruby", "java"]
    }

    test "paginate_audiences/1 returns paginated results" do
      insert_list(25, :audience, @valid_attrs)
      {:ok, results} = Audiences.paginate_audiences(nil)
      assert results.distance == 5
      assert results.page_number == 1
      assert results.page_size == 15
      assert results.sort_direction == "desc"
      assert results.sort_field == "inserted_at"
      assert results.total_entries == 25
      assert results.total_pages == 2
      assert length(results.audiences) == 15
    end

    test "get_audience!/1 returns the audience with given id" do
      audience = insert(:audience, @valid_attrs)
      assert Audiences.get_audience!(audience.id).id == audience.id
    end

    test "create_audience/1 with valid data creates a audience" do
      assert {:ok, %Audience{} = audience} =
               Audiences.create_audience(
                 string_params_with_assocs(
                   :audience,
                   name: "Some Audience",
                   programming_languages: ["ruby"]
                 )
               )

      assert audience.name == "Some Audience"
      assert audience.programming_languages == ["ruby"]
    end

    test "create_audience/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Audiences.create_audience(@invalid_attrs)
    end

    test "change_audience/1 returns changeset" do
      assert %Ecto.Changeset{} = Audiences.change_audience(%Audience{})
    end

    test "update_audience/2 with valid data updates the audience" do
      audience = insert(:audience)
      assert {:ok, audience} = Audiences.update_audience(audience, @update_attrs)
      assert %Audience{} = audience
      assert audience.name == "New Name"
      assert audience.programming_languages == ["ruby", "java"]
    end

    test "update_audience/2 with invalid data returns error changeset" do
      audience = insert(:audience)
      assert {:error, %Ecto.Changeset{}} = Audiences.update_audience(audience, @invalid_attrs)
      assert audience == Audiences.get_audience!(audience.id)
    end

    test "delete_audience/1 deletes the audience" do
      audience = insert(:audience)
      assert {:ok, %Audience{}} = Audiences.delete_audience(audience)
      assert_raise Ecto.NoResultsError, fn -> Audiences.get_audience!(audience.id) end
    end
  end
end
