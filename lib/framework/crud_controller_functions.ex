defmodule Framework.CRUDControllerFunctions do
  import Framework.Module
  use CodeFundWeb, :controller

  @all_actions [
    :index,
    :new,
    :create,
    :show,
    :edit,
    :update,
    :delete
  ]

  defmacro __using__([schema, :all]) do
    build_actions(schema, @all_actions)
  end

  defmacro __using__([schema, :all, except: exclusions]) when is_list(exclusions) do
    build_actions(schema, @all_actions -- exclusions)
  end

  defmacro __using__([schema, actions]) when is_list(actions) do
    build_actions(schema, actions)
  end

  @spec build_actions(String.t(), list) :: Macro.t()
  def build_actions(schema, actions) when is_list(actions) do
    for action <- actions do
      build_action(schema, action, [])
    end
  end

  @spec build_action(String.t(), atom, list) :: Macro.t()
  def build_action(schema, action, block) when is_list(block) do
    quote do
      def unquote(action)(conn, params) do
        block = unquote(block)

        conn =
          case Keyword.has_key?(block, :hooks) do
            true -> Framework.CRUDControllerFunctions.assign(conn, block[:hooks].(conn, params))
            false -> conn
          end
          |> Framework.CRUDControllerFunctions.assign(block[:assigns] || [])

        Framework.CRUDControllerFunctions.stubs(unquote(action), unquote(schema), conn, params)
      end
    end
  end

  @spec assign(Plug.Conn.t(), list) :: Plug.Conn.t()
  def assign(conn, assigns) do
    assigns = assigns |> Enum.into(%{}) |> Map.merge(conn.assigns)
    Map.put(conn, :assigns, assigns)
  end

  @spec assign(atom, list) :: Macro.t()
  defmacro defstub(definition, do: block) when is_list(block) do
    {function, [schema]} = Macro.decompose_call(definition)
    build_action(schema, function, block)
  end

  @spec stubs(atom, String.t(), %Plug.Conn{}, map) :: %Plug.Conn{}
  def stubs(:index, schema, conn, params) do
    case apply(module_name(schema, :context), paginate(schema), [current_user(conn), params]) do
      {:ok, assigns} ->
        render(conn, "index.html", Map.merge(assigns, %{schema: schema}))

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
      CodeFundWeb.SharedView,
      "form_container.html",
      schema: schema,
      action: :create,
      conn: conn
    )
  end

  def stubs(:create, schema, conn, params) do
    module_name(schema, :context)
    |> apply(:"create_#{pretty(schema, :downcase, :singular)}", [
      fetch_post_params(schema, params)
    ])
    |> case do
      {:ok, object} ->
        conn
        |> put_flash(:info, "#{pretty(schema, :upcase, :singular)} created successfully.")
        |> redirect(to: path(schema, conn, :show, object))

      {:error, changeset} ->
        report(:warning, "Changeset Error")

        conn
        |> put_status(422)
        |> render(
          CodeFundWeb.SharedView,
          "form_container.html",
          schema: schema,
          conn: conn,
          action: :create,
          changeset: changeset
        )
    end
  end

  def stubs(:show, schema, conn, %{"id" => id}) do
    render(
      conn,
      "show.html",
      Keyword.new([
        {pretty(schema, :downcase, :singular) |> String.to_atom(), get!(schema, id)},
        {:schema, schema}
      ])
    )
  end

  def stubs(:edit, schema, conn, %{"id" => id}) do
    object = get!(schema, id)
    current_user = current_user(conn)

    render(
      conn,
      CodeFundWeb.SharedView,
      "form_container.html",
      Keyword.new([
        {pretty(schema, :downcase, :singular) |> String.to_atom(), object},
        {:schema, schema},
        {:object, object},
        {:action, :update},
        {:conn, conn},
        {:current_user, current_user}
      ])
    )
  end

  def stubs(:update, schema, conn, %{"id" => id} = params) do
    object = get!(schema, id)
    current_user = current_user(conn)

    module_name(schema, :context)
    |> apply(:"update_#{pretty(schema, :downcase, :singular)}", [
      object,
      fetch_post_params(schema, params)
    ])
    |> case do
      {:ok, object} ->
        conn
        |> put_flash(:info, "#{pretty(schema, :upcase, :singular)} updated successfully.")
        |> redirect(to: path(schema, conn, :show, object))

      {:error, changeset} ->
        report(:warning, "Changeset Error")

        conn
        |> put_status(422)
        |> render(
          CodeFundWeb.SharedView,
          "form_container.html",
          Keyword.new([
            {pretty(schema, :downcase, :singular) |> String.to_atom(), object},
            {:schema, schema},
            {:object, object},
            {:action, :update},
            {:conn, conn},
            {:current_user, current_user},
            {:changeset, changeset}
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

  @spec get!(String.t(), UUID.t()) :: struct
  defp get!(schema, id),
    do:
      apply(module_name(schema, :context), :"get_#{pretty(schema, :downcase, :singular)}!", [id])

  @spec current_user(%Plug.Conn{}) :: %CodeFund.Schema.User{}
  defp current_user(conn), do: conn.assigns.current_user

  @spec paginate(String.t()) :: atom
  defp paginate(schema), do: :"paginate_#{schema |> String.downcase() |> Inflex.pluralize()}"

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

  @spec fetch_object_params(String.t(), map) :: any()
  defp fetch_object_params(schema, params), do: params[schema |> String.downcase()]

  @spec fetch_post_params(String.t(), map) :: any()
  defp fetch_post_params(schema, params) do
    fetch_object_params(schema, params["params"])
  end
end
