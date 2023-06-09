defmodule PhonebookOld do
  @filename Application.compile_env(:phonebook_old, :file)

  def filename, do: @filename

  def find(name) do
    list = file_content(@filename)

    string =
      list
      |> Enum.find(fn el ->
        String.contains?(String.downcase(el), String.downcase(name))
      end)

    string
    |> String.split()
    |> List.last()
  end

  def list() do
    list = file_content(@filename)

    Enum.reduce(list, %{}, fn string, acc ->
      [name, phone] = String.split(string)
      Map.put(acc, name, phone)
    end)
  end

  def find_all(letters) do
    list = file_content(@filename)

    list
    |> Enum.filter(fn el ->
      String.contains?(String.downcase(el), String.downcase(letters))
    end)
    |> Enum.map(fn string ->
      string
      |> String.split()
      |> List.last()
    end)
  end

  def add_phone(name, number) do
    if File.exists?(@filename) do
      if name_or_number_exists_in_file?(name, number) do
        IO.inspect("Boom! The number or name is already exist!")
        {:error, :number_exists}
      else
        File.write(@filename, "\r\n", [:write, :append])
        File.write(@filename, "#{name} #{number}", [:write, :append])
      end
    else
      File.write(@filename, "#{name} #{number}", [:write, :append])
    end
  end

  defp name_or_number_exists_in_file?(name, number) do
    Enum.find(list(), fn {k, v} ->
      k == name or v == number
    end)
  end

  defp name_exists_in_file?(name) do
    Enum.find(list(), fn {k, _v} ->
      k == name
    end)
  end

  defp number_exists_in_file?(number) do
    Enum.find(list(), fn {_k, v} ->
      v == number
    end)
  end

  def update_phone(name, number) do
    if File.exists?(@filename) do
      if name_exists_in_file?(name) do
        if number_exists_in_file?(number) do
          {:error, :number_is_taken}
        else
          update_number_for_name(name, number)
        end
      else
        {:error, :no_such_name}
      end
    else
      {:error, :no_file}
    end
  end

  def update_number_for_name(name, number) do
    new_list =
      Enum.reduce(list(), %{}, fn {k, v}, acc ->
        if k == name do
          Map.put(acc, k, number)
        else
          Map.put(acc, k, v)
        end
      end)

    File.rm(@filename)

    Enum.each(new_list, fn {k, v} ->
      File.write(@filename, "#{k} #{v}\r\n", [:write, :append])
    end)

    {:ok, :updated}
  end

  def file_content(filename) do
    {:ok, content} = File.read(filename)

    content
    |> String.split("\r\n")
    |> Enum.reject(&(&1 == ""))
  end
end
