defmodule Mix.Tasks.PhoneTest do
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

  test "all" do
    output = Mix.Tasks.Phone.run(["all"])
  end

  test "find" do
    list = Mix.Tasks.Phone.run(["find", "asma"])
    assert length(list) > 0
  end

  test "add success" do
    output = Mix.Tasks.Phone.run(["add", "William", "123", "Berlin 456"])
    assert output =~ "The contact William, 123, Berlin 456"
    assert String.starts_with?(output, "The contact William, 123, Berlin 456")
  end

  test "add error" do
    output = Mix.Tasks.Phone.run(["add", "Anton", "123", "Berlin 456"])
    assert output == "The contact Anton already exists in the phonebook."
  end

  test "update success" do
    output = Mix.Tasks.Phone.run(["update", "Asma", "8888", "Alexander"])
    assert output =~ "The contact Asma has been updated to 8888, Alexander"
    assert String.starts_with?(output, "The contact Asma has been updated to 8888, Alexander")
  end

  test "update error" do
    output = Mix.Tasks.Phone.run(["update", "Wasma", "8888", "Alexander"])
    assert output == "This contact Wasma does not exists in the phonebook."
  end

  test "delete success" do
    output = Mix.Tasks.Phone.run(["delete", "Asma"])
    assert output =~ "The contact Asma has been deleted"
    assert String.starts_with?(output, "The contact Asma has been deleted")
  end

  test "delete error" do
    output = Mix.Tasks.Phone.run(["delete", "Wasma"])
    assert output == "The contact Wasma does not exists in the phonebook."
  end
end
