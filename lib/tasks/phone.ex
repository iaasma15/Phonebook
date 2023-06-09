defmodule Mix.Tasks.Phone do
  @moduledoc """
    CLI - command line interface
    - mix phone all - prints all the contacts
    - mix phone find term - prints all the contacts with the term inside
    - mix phone add name number address - prints a new contact or an error message
    - mix phone update name number address - prints the updated contact or an error message
    - mix phone delete name - prints the deleted contact or an error message

  """

  use Mix.Task

  def run(opts) do
    [action | args] = opts

    case action do
      "all" ->
        Phonebook.all_contacts()
        |> IO.inspect()

      "find" ->
        args
        |> List.first()
        |> Phonebook.find()
        |> IO.inspect()

      "add" ->
        [name, number, address] = args

        case Phonebook.add_contact(name, number, address) do
          {:ok, :contact_added} ->
            IO.inspect("The contact #{name}, #{number}, #{address} has been successfully added.")

          {:error, :contact_exists} ->
            IO.inspect("The contact #{name} already exists in the phonebook.")
        end

      "update" ->
        [name, number, address] = args

        case Phonebook.update_contact(name, number, address) do
          {:ok, :updated} ->
            IO.inspect("The contact #{name} has been updated to #{number}, #{address}")

          {:error, :contact_not_found} ->
            IO.inspect("This contact #{name} does not exists in the phonebook.")
        end

      "delete" ->
        [name] = args

        case Phonebook.delete_contact(name) do
          {:ok, :contact_deleted} ->
            IO.inspect("The contact #{name} has been deleted")

          {:error, :contact_not_found} ->
            IO.inspect("The contact #{name} does not exists in the phonebook.")
        end
    end
  end
end
