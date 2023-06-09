defmodule PhonebookTest do
  use ExUnit.Case

  @content """
  [
    {
      "name": "Asma",
      "number": "1234",
      "address": "Berlin 5"
    },
    {
      "name": "Anton",
      "number": "6789",
      "address": "Torstrasse 5"
    },
    {
      "name": "Nick",
      "number": "999",
      "address": "Neukoln 777"
    }
  ]
  """

  @filename Application.compile_env(:phonebook, :file)

  setup do
    File.rm(@filename)
    File.write(@filename, @content, [:write])
    :ok
  end

  test "read_file/0" do
    list = Phonebook.read_file()
    assert length(list) == 3
    asma_contact = List.first(list)
    assert asma_contact["name"] == "Asma"
    assert asma_contact["number"] == "1234"
    assert asma_contact["address"] == "Berlin 5"
  end

  test "write_file/1" do
    File.rm(@filename)

    list = [
      %{
        "name" => "Asma",
        "number" => "1234",
        "address" => "Berlin 5"
      },
      %{
        "name" => "Anton",
        "number" => "6789",
        "address" => "Torstrasse 5"
      }
    ]

    Phonebook.write_file(list)
    updated_list = Phonebook.read_file()

    assert updated_list == list
    list = Phonebook.read_file()
    assert length(list) == 2
    asma_contact = List.first(list)
    assert asma_contact["name"] == "Asma"
    assert asma_contact["number"] == "1234"
    assert asma_contact["address"] == "Berlin 5"
  end

  describe "find/1" do
    test "it finds records, different scenarios" do
      asma_contact = %{"name" => "Asma", "number" => "1234", "address" => "Berlin 5"}
      assert Phonebook.find("Asma") == [asma_contact]
      assert Phonebook.find("asma") == [asma_contact]
      assert Phonebook.find("sma") == [asma_contact]
      assert Phonebook.find("234") == [asma_contact]
      assert Phonebook.find("berl") == [asma_contact]
      assert Phonebook.find("William") == []
    end
  end

  describe "get" do
    test "it get a record" do
      assert Phonebook.get("Asma") ==
               {:ok, %{"name" => "Asma", "number" => "1234", "address" => "Berlin 5"}}
    end

    test "not found" do
      assert Phonebook.get("Nope") == {:error, :contact_not_found}
    end
  end

  describe "add_contact/3" do
    test "success case" do
      assert Phonebook.add_contact("William", "929928", "Hansaplatz") == {:ok, :contact_added}
      # updated_list = Phonebook.read_file()
      # william_record = Enum.find(updated_list, fn(contact) ->
      #   contact["name"] == "William"
      # end)
      # assert william_record == %{"name" => "William", "number" =>"929928", "address" =>"Hansaplatz"}
      assert Phonebook.find("William") == [
               %{"name" => "William", "number" => "929928", "address" => "Hansaplatz"}
             ]
    end

    test "fail case, contact already exists" do
      assert Phonebook.add_contact("Asma", "any", "any") == {:error, :contact_exists}
    end
  end

  describe "delete_contact/1" do
    test "success case" do
      assert Phonebook.delete_contact("Asma") == {:ok, :contact_deleted}
      assert Phonebook.find("Asma") == []
    end

    test "fail case" do
      assert Phonebook.delete_contact("William") == {:error, :contact_not_found}
    end
  end

  describe "update_contact/3" do
    test "success case" do
      assert Phonebook.update_contact("Asma", "34567", "Adeneurplatz") == {:ok, :updated}

      assert Phonebook.find("Asma") == [
               %{"name" => "Asma", "number" => "34567", "address" => "Adeneurplatz"}
             ]
    end

    test "fail case" do
      assert Phonebook.update_contact("William", "any", "any") == {:error, :contact_not_found}
    end
  end
end
