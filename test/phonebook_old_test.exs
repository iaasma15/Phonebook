# defmodule PhonebookOldTest do
#   use ExUnit.Case

#   setup do
#     filename = Application.get_env(:phonebook_old, :file)
#     File.rm(filename)
#     File.write(filename, "Asma 123\r\nKloeckner.i 456\r\nAnton 789", [:write])
#     %{filename: filename}
#   end

#   test "find" do
#     assert PhonebookOld.find("Kloeckner.i") == "456"
#     assert PhonebookOld.find("Asma") == "123"
#     assert PhonebookOld.find("Anton") == "789"
#   end

#   test "find with lowercase" do
#     assert PhonebookOld.find("kloeckner.i") == "456"
#     assert PhonebookOld.find("asma") == "123"
#     assert PhonebookOld.find("anton") == "789"
#   end

#   test "find_all" do
#     assert PhonebookOld.find_all("s") == ["123"]
#     assert PhonebookOld.find_all("o") == ["456", "789"]
#   end

#   test "list" do
#     numbers = PhonebookOld.list()

#     assert numbers == %{
#              "Asma" => "123",
#              "Kloeckner.i" => "456",
#              "Anton" => "789"
#            }
#   end

#   test "file_content/1", %{filename: filename} do
#     result = PhonebookOld.file_content(filename)
#     assert result == ["Asma 123", "Kloeckner.i 456", "Anton 789"]
#   end

#   test "add_phone to existing file", %{filename: filename} do
#     PhonebookOld.add_phone("Robert", "555")

#     result = PhonebookOld.file_content(filename)
#     assert result == ["Asma 123", "Kloeckner.i 456", "Anton 789", "Robert 555"]
#   end

#   test "add_phone when there is no file", %{filename: filename} do
#     File.rm(filename)
#     PhonebookOld.add_phone("Asma", "123")
#     PhonebookOld.add_phone("Anton", "789")

#     result = PhonebookOld.file_content(filename)
#     assert result == ["Asma 123", "Anton 789"]
#   end

#   test "add_phone when the name or number is already exists", %{filename: filename} do
#     {:ok, content_before} = File.read(filename)
#     assert PhonebookOld.add_phone("Asma", "123") == {:error, :number_exists}
#     assert PhonebookOld.add_phone("William", "123") == {:error, :number_exists}
#     assert PhonebookOld.add_phone("Asma", "666") == {:error, :number_exists}
#     {:ok, content_after} = File.read(filename)
#     assert content_before == content_after

#     assert PhonebookOld.add_phone("Robert", "45") == :ok
#     assert PhonebookOld.add_phone("Patrick", "6773") == :ok
#   end

#   test "update_number_for_name/2" do
#     PhonebookOld.update_number_for_name("Anton", "777")
#     assert PhonebookOld.find("Anton") == "777"
#     PhonebookOld.update_number_for_name("Asma", "666")
#     assert PhonebookOld.find("Asma") == "666"
#   end

#   test "update_phone when the name is in file (success case)", %{filename: filename} do
#     assert PhonebookOld.update_phone("Anton", "777") == {:ok, :updated}
#     assert PhonebookOld.update_phone("Anton", "123") == {:error, :number_is_taken}
#     assert PhonebookOld.update_phone("William", "123") == {:error, :no_such_name}

#     File.rm(filename)
#     assert PhonebookOld.update_phone("William", "123") == {:error, :no_file}
#   end
# end
