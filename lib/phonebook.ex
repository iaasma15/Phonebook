defmodule Phonebook do
  @filename Application.compile_env(:phonebook, :file)

  def filename, do: @filename

  @doc "Reads the file and returns list of contacts"
  def read_file() do
    @filename
    |> File.read!()
    |> Jason.decode!()
  end

  @doc "Write the JSON representation of the list to the file"
  def write_file(list) do
    content = Jason.encode!(list)
    File.write(@filename, content, [:write])
  end

  @doc "Returns a list of contacts where either name or number or address match the term"
  def find(term) do
    list = read_file()
    # Enum.reduce
    Enum.reduce(list, [], fn contact, acc ->
      name = Map.get(contact, "name")
      number = Map.get(contact, "number")
      address = Map.get(contact, "address")

      any? =
        Enum.any?([name, number, address], fn part ->
          String.contains?(String.downcase(part), String.downcase(term))
        end)

      if any? do
        [contact | acc]
      else
        acc
      end
    end)
  end

  def get(name) do
    list = read_file()

    case Enum.find(list, fn contact -> contact["name"] == name end) do
      nil ->
        {:error, :contact_not_found}

      contact ->
        {:ok, contact}
    end
  end

  @doc "Return all teh contacts"
  def all_contacts() do
    read_file()
  end

  @doc """
    Adds a new contact to the phonebook
    contact is a map
    %{
        "name": "Asma",
        "number": "1234",
        "address": "Berlin 5"
    }
  """
  def add_contact(name, number, address) do
    list = read_file()

    new_contact = %{
      "name" => name,
      "number" => number,
      "address" => address
    }

    if contact_exists?(list, name) do
      {:error, :contact_exists}
    else
      updated_contacts = [new_contact | list]
      write_file(updated_contacts)
      {:ok, :contact_added}
    end
  end

  defp contact_exists?(list, name) do
    # Enum.any?(list, fn contact -> contact["name"] == name end)
    Enum.any?(list, &(&1["name"] == name))
  end

  # def add_contact(contact) do
  #   # check if name already exists
  #   # and other contidions
  #   # write to file
  # end

  @doc "deletes the contact for the given name"
  def delete_contact(name) do
    list = read_file()
    # check if name already exists
    # and other contidions
    # write to file
    if contact_exists?(list, name) do
      updated_contacts =
        Enum.filter(list, fn contact ->
          contact["name"] != name
        end)

      write_file(updated_contacts)
      {:ok, :contact_deleted}
    else
      {:error, :contact_not_found}
    end
  end

  @doc """
    Adds a new contact to the phonebook
    name is a string, like "Anton"
    contact is a map
    %{
        "name": "Anton",
        "number": "1234",
        "address": "Berlin 5"
    }
  """
  # TODO return {:error, :contact_not_found} when there is no such contact
  def update_contact(name, number, address) do
    list = read_file()

    if contact_exists?(list, name) do
      updated_contact =
        Enum.map(list, fn contact ->
          if Map.get(contact, "name") == name do
            contact
            |> Map.put("address", address)
            |> Map.put("number", number)

            # Map.merge(contact, %{"address" => address, "number" => number}
          else
            contact
          end
        end)

      write_file(updated_contact)
      {:ok, :updated}
    else
      {:error, :contact_not_found}
    end
  end
end
