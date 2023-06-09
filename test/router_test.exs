defmodule RouterTest do
  use ExUnit.Case
  use Plug.Test

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

  describe "list the contacts" do
    test "contacts" do
      conn =
        :get
        |> conn("/contacts")
        |> Phonebook.Router.call(%{})

      assert conn.resp_body =~ "Asma"
      assert conn.resp_body =~ "Anton"
      assert conn.resp_body =~ "Nick"
    end
  end

  describe "create a new contact" do
    test "new contact page" do
      conn =
        :get
        |> conn("/contacts/new")
        |> Phonebook.Router.call(%{})

      assert conn.resp_body =~ "Add new contact"
      assert conn.resp_body =~ "Name"
      assert conn.resp_body =~ "form action="
    end

    test "do create a new contact" do
      payload = %{"name" => "Stavros", "address" => "Berlin 123", "number" => "555"}

      conn =
        :post
        |> conn("/contacts", URI.encode_query(payload))
        |> Phonebook.Router.call(%{})

      assert conn.status == 302
      assert Enum.member?(conn.resp_headers, {"location", "/contacts"})

      conn =
        :get
        |> conn("/contacts")
        |> Phonebook.Router.call(%{})

      assert conn.resp_body =~ "Stavros"
      assert conn.resp_body =~ "Berlin 123"
      assert conn.resp_body =~ "555"
    end

    test "do not create a contact with the same name" do
      payload = %{"name" => "Anton", "address" => "Berlin 123", "number" => "555"}

      conn =
        :post
        |> conn("/contacts", URI.encode_query(payload))
        |> Phonebook.Router.call(%{})

      assert conn.status == 409
      assert conn.resp_body =~ "Contact already exists!"
    end
  end

  describe "show contact /contacts/:name" do
    test "show the contact we clicked" do
      conn =
        :get
        |> conn("/contacts/Asma")
        |> Phonebook.Router.call(%{})

      assert conn.status == 200
      assert conn.resp_body =~ "Edit Contact"
      assert conn.resp_body =~ "form action="
    end
  end

  describe "edit contact form page" do
    test "edit page shows form" do
      conn =
        :get
        |> conn("/contacts/Anton/edit")
        |> Phonebook.Router.call(%{})

      assert conn.resp_body =~ "form action="
      assert conn.status == 200
    end

    test "if the contact does not exist" do
      conn =
        :get
        |> conn("/contacts/Rosy/edit")
        |> Phonebook.Router.call(%{})

      assert conn.status == 404
      assert conn.resp_body =~ "Contact not found!"
    end
  end

  describe "update" do
    test "post request to update contact" do
      payload = %{"name" => "Anton", "address" => "Hackersher 123", "number" => "555"}

      conn =
        :post
        |> conn("/contacts/Anton/update", URI.encode_query(payload))
        |> Phonebook.Router.call(%{})

      assert conn.status == 302
      assert Enum.member?(conn.resp_headers, {"location", "/contacts/Anton"})

      conn =
        :get
        |> conn("/contacts/Anton")
        |> Phonebook.Router.call(%{})

      assert conn.resp_body =~ "Anton"
      assert conn.resp_body =~ "Hackersher 123"
      assert conn.resp_body =~ "555"
    end
  end

  describe "delete" do
    # TODO
    test "post request to delete a contact" do
      conn =
        :post
        |> conn("/contacts/Asma/delete")
        |> Phonebook.Router.call(%{})

      assert conn.status == 302
      assert Enum.member?(conn.resp_headers, {"location", "/contacts"})

      conn =
        :get
        |> conn("/contacts")
        |> Phonebook.Router.call(%{})

      refute conn.resp_body =~ "Asma"
    end
  end
end
