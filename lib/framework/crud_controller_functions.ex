defmodule Framework.CRUDControllerFunctions do
  use CodeFundWeb, :controller

  defmacro __using__([schema, :all, except: list]) do
    for action <- all() -- list do
      build_action(schema, action)
    end
  end

  defmacro __using__([schema, :all]) do
    for action <- all() do
      build_action(schema, action)
    end
  end

  defmacro __using__([schema, actions]) do
    for action <- actions do
      build_action(schema, action)
    end
  end

  def all() do
    [
      :index,
      :new,
      :create,
      :show,
      :edit,
      :update,
      :delete
    ]
  end

  def build_action(schema, action) do
    quote do
      def unquote(action)(conn, params) do
        Framework.CRUDControllerFunctions.stubs(unquote(action), unquote(schema), conn, params)
      end
    end
  end

  @spec stubs(atom, String.t(), %Plug.Conn{}, map) :: %Plug.Conn{}
  def stubs(:index, schema, conn, params) do
    case apply(module_name(schema, :context), paginate(schema), [current_user(conn), params]) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)

      error ->
        report(:error)

        conn
        |> put_flash(
          :error,
          "There was an error rendering #{pretty(schema, :upcase, :plural)}. #{inspect(error)}"
        )
        |> redirect(to: path(schema, conn, :index))
    end
  end

  def stubs(:new, schema, conn, _params) do
    render(
      conn,
      "new.html",
      form:
        new_formex(
          schema,
          false,
          %{},
          associations(schema, current_user(conn), [])
        )
    )
  end

  def stubs(:create, schema, conn, params) do
    new_formex(
      schema,
      false,
      fetch_object_params(schema, params),
      associations(schema, current_user(conn), [])
    )
    |> insert_form_data
    |> case do
      {:ok, object} ->
        conn
        |> put_flash(:info, "#{pretty(schema, :upcase, :singular)} created successfully.")
        |> redirect(to: path(schema, conn, :show, object))

      {:error, form} ->
        report(:warn, "Changeset Error")

        conn
        |> put_status(422)
        |> render("new.html", form: form)
    end
  end

  def stubs(:show, schema, conn, %{"id" => id}) do
    render(
      conn,
      "show.html",
      Keyword.new([{pretty(schema, :downcase, :singular) |> String.to_atom(), get!(schema, id)}])
    )
  end

  def stubs(:edit, schema, conn, %{"id" => id}) do
    object = get!(schema, id)
    current_user = current_user(conn)

    render(
      conn,
      "edit.html",
      Keyword.new([
        {pretty(schema, :downcase, :singular) |> String.to_atom(), object},
        {:form,
         new_formex(
           schema,
           object,
           %{},
           user: object |> Map.get(:user) || object,
           current_user: current_user
         )}
      ])
    )
  end

  def stubs(:update, schema, conn, %{"id" => id} = params) do
    object = get!(schema, id)
    current_user = current_user(conn)

    new_formex(
      schema,
      object,
      fetch_object_params(schema, params),
      user: object |> Map.get(:user) || object,
      current_user: current_user
    )
    |> update_form_data
    |> case do
      {:ok, object} ->
        conn
        |> put_flash(:info, "#{pretty(schema, :upcase, :singular)} updated successfully.")
        |> redirect(to: path(schema, conn, :show, object))

      {:error, form} ->
        report(:warn, "Changeset Error")

        conn
        |> put_status(422)
        |> render(
          "edit.html",
          Keyword.new([
            {pretty(schema, :downcase, :singular) |> String.to_atom(), object},
            {:form, form}
          ])
        )
    end
  end

  def stubs(:delete, schema, conn, %{"id" => id}) do
    {:ok, _object} =
      module_name(schema, :context)
      |> apply(:"delete_#{pretty(schema, :downcase, :singular)}", [get!(schema, id)])

    conn
    |> put_flash(:info, "#{pretty(schema, :upcase, :singular)} deleted successfully.")
    |> redirect(to: path(schema, conn, :index))
  end

  @spec current_user(%Plug.Conn{}) :: %CodeFund.Schema.User{}
  defp current_user(conn), do: conn.assigns.current_user

  @spec paginate(String.t()) :: atom
  defp paginate(schema), do: :"paginate_#{schema |> String.downcase() |> Inflex.pluralize()}"

  @spec get!(String.t(), UUID.t()) :: struct
  defp get!(schema, id),
    do:
      apply(module_name(schema, :context), :"get_#{pretty(schema, :downcase, :singular)}!", [id])

  @spec pretty(String.t(), atom, atom) :: String.t()
  defp pretty(schema, :upcase, :singular), do: schema
  defp pretty(schema, :upcase, :plural), do: schema |> Inflex.pluralize()
  defp pretty(schema, :downcase, :singular), do: "#{schema |> String.downcase()}"

  defp pretty(schema, :downcase, :plural),
    do: pretty(schema, :downcase, :singular) |> Inflex.pluralize()

  @spec path(String.t(), %Plug.Conn{}, atom) :: String.t()
  defp path(schema, conn, action),
    do:
      apply(CodeFundWeb.Router.Helpers, :"#{pretty(schema, :downcase, :singular)}_path", [
        conn,
        action
      ])

  @spec path(String.t(), %Plug.Conn{}, atom, Ecto.Schema.t()) :: String.t()
  defp path(schema, conn, action, object),
    do:
      apply(CodeFundWeb.Router.Helpers, :"#{pretty(schema, :downcase, :singular)}_path", [
        conn,
        action,
        object
      ])

  @spec module_name(String.t(), atom) :: atom
  defp module_name(schema, :context),
    do: Module.concat([CodeFund, "#{schema |> Inflex.pluralize()}"])

  defp module_name(schema, :formex_type),
    do: Module.concat([CodeFundWeb, "#{schema}Type" |> String.to_atom()])

  defp module_name(schema, :struct_name),
    do: Module.concat([CodeFund, Schema, schema |> String.to_atom()])

  defp module_name(schema, :struct), do: schema |> module_name(:struct_name) |> struct()

  @spec fetch_object_params(String.t(), map) :: any()
  defp fetch_object_params(schema, params), do: params[schema |> String.downcase()]

  @spec new_formex(String.t(), false | Ecto.Schema.t(), map, Keyword.t()) :: struct
  defp new_formex(schema, false, params, opts) do
    new_formex(
      schema,
      module_name(schema, :struct),
      params,
      opts
    )
  end

  defp new_formex(schema, object, params, opts) do
    apply(Formex.Builder, :create_form, [
      module_name(schema, :formex_type),
      object,
      params,
      opts
    ])
  end

  @spec associations(String.t(), %CodeFund.Schema.User{}, Keyword.t()) :: Keyword.t()
  defp associations(schema, user, opts), do: associations(schema, user, user, opts)

  @spec associations(String.t(), %CodeFund.Schema.User{}, %CodeFund.Schema.User{}, Keyword.t()) ::
          Keyword.t()
  defp associations(schema, user, current_user, opts) do
    opts = Enum.concat(opts, current_user: current_user)

    case apply(module_name(schema, :struct_name), :__schema__, [:associations])
         |> Enum.member?(:user) do
      true -> [user: user] |> Enum.concat(opts)
      false -> opts
    end
  end
end
