# HTTP REST API for our Phonrbook app
defmodule Phonebook.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "Welcome")
  end

  get "/hello" do
    conn = fetch_query_params(conn)
    name = conn.params["name"]
    send_resp(conn, 200, "Hello #{name}!")
  end

  get "/contacts" do
    conn = fetch_query_params(conn)
    term = conn.params["search"]

    contacts =
      if term do
        Phonebook.find(term)
      else
        Phonebook.all_contacts()
      end

    table_html =
      EEx.eval_file(
        "templates/table.eex.html",
        title: "Contact Lists",
        action: "/contacts",
        subtitle1: "Name",
        subtitle2: "Number",
        subtitle3: "Address",
        subtitle4: "Actions",
        contacts: contacts
      )

    html = EEx.eval_file("templates/layout.eex.html", content: table_html)
    send_resp(conn, 200, html)
  end

  get "/contacts/new" do
    form =
      EEx.eval_file(
        "templates/form.eex.html",
        title: "Add new contact:",
        action: "/contacts",
        name: "",
        number: "",
        address: "",
        disabled: false
      )

    html = EEx.eval_file("templates/layout.eex.html", content: form)
    send_resp(conn, 200, html)
  end

  get "/contacts/:name" do
    name = conn.params["name"]

    case Phonebook.get(name) do
      {:ok, contact} ->
        show_html =
          EEx.eval_file(
            "templates/show.eex.html",
            name: contact["name"],
            number: contact["number"],
            address: contact["address"]
          )

        html = EEx.eval_file("templates/layout.eex.html", content: show_html)
        send_resp(conn, 200, html)

      {:error, :contact_not_found} ->
        send_resp(conn, 404, "Contact not found!")
    end
  end

  get "/contacts/:name/edit" do
    name = conn.params["name"]

    case Phonebook.get(name) do
      {:ok, contact} ->
        form =
          EEx.eval_file(
            "templates/form.eex.html",
            title: "Edit contact: #{name}",
            action: "/contacts/#{contact["name"]}/update",
            name: contact["name"],
            number: contact["number"],
            address: contact["address"],
            disabled: true
          )

        html = EEx.eval_file("templates/layout.eex.html", content: form)
        send_resp(conn, 200, html)

      {:error, :contact_not_found} ->
        send_resp(conn, 404, "Contact not found!")
    end
  end

  post "/contacts" do
    {:ok, body, conn} = read_body(conn)
    params = URI.decode_query(body)

    case Phonebook.add_contact(params["name"], params["number"], params["address"]) do
      {:ok, :contact_added} ->
        conn
        |> put_resp_header("location", "/contacts")
        |> send_resp(302, "")

      {:error, :contact_exists} ->
        send_resp(conn, 409, "Contact already exists!")
    end
  end

  post "/contacts/:name/update" do
    {:ok, body, conn} = read_body(conn)
    name = conn.params["name"]
    params = URI.decode_query(body)

    case Phonebook.update_contact(name, params["number"], params["address"]) do
      {:ok, :updated} ->
        conn
        |> put_resp_header("location", "/contacts/#{name}")
        |> send_resp(302, "")

      {:error, :contact_not_found} ->
        send_resp(conn, 409, "Contact not found!")
    end
  end

  post "/contacts/:name/delete" do
    name = conn.params["name"]

    case Phonebook.delete_contact(name) do
      {:ok, :contact_deleted} ->
        conn
        |> put_resp_header("location", "/contacts")
        |> send_resp(302, "")

      {:error, :contact_not_found} ->
        send_resp(conn, 409, "Contact not found!")
    end
  end

  get "/styles.css" do
    send_file(conn, 200, "templates/styles.css")
  end

  get "/script.js" do
    send_file(conn, 200, "templates/script.js")
  end

  match _ do
    send_resp(conn, 404, "Oops!")
  end
end
