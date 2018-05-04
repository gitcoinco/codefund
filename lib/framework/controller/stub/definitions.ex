defmodule Framework.Controller.Stub.Definitions do
  import Framework.{Module, Path}
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
  defp build_actions(schema, actions) when is_list(actions) do
    for action <- actions do
      build_action(schema, action, [])
    end
  end

  @spec build_action(String.t(), atom, list) :: Macro.t()
  def build_action(schema, action, block) do
    quote do
      def unquote(action)(conn, params) do
        block = unquote(block)

        after_hooks = [
          success: block[:after_hooks][:success] || fn _object, _params -> [] end,
          error: block[:after_hooks][:error] || fn _conn, _params -> [] end
        ]

        params =
          case Keyword.has_key?(block, :params) do
            true ->
              {key, value} = block[:params].(conn, params)

              put_in(
                params,
                ["params", pretty(unquote(schema), :downcase, :singular), key],
                value
              )

            false ->
              params
          end

        conn =
          case Keyword.has_key?(block, :before_hook) do
            true ->
              Framework.Controller.Stub.Definitions.assign(
                conn,
                block[:before_hook].(conn, params)
              )

            false ->
              conn
          end
          |> Framework.Controller.Stub.Definitions.assign(block[:assigns] || [])

        Framework.Controller.Stub.Definitions.action(
          unquote(action),
          unquote(schema),
          conn,
          params,
          after_hooks
        )
      end
    end
  end

  @spec assign(Plug.Conn.t(), list) :: Plug.Conn.t()
  def assign(conn, assigns) do
    assigns = assigns |> Enum.into(%{}) |> Map.merge(conn.assigns)
    Map.put(conn, :assigns, assigns)
  end

  @spec action(atom, String.t(), %Plug.Conn{}, map, list) :: %Plug.Conn{}
  def action(:index, schema, conn, params, _after_hooks) do
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
        |> redirect(to: construct_path(conn, :index))
    end
  end

  def action(:new, schema, conn, _params, _after_hooks) do
    render(
      conn,
      CodeFundWeb.SharedView,
      "form_container.html",
      schema: schema,
      action: :create,
      conn: conn
    )
  end

  def action(:create, schema, conn, params, after_hooks) do
    module_name(schema, :context)
    |> apply(:"create_#{pretty(schema, :downcase, :singular)}", [
      fetch_post_params(schema, params)
    ])
    |> case do
      {:ok, object} ->
        after_hooks[:success].(object, params)

        conn =
          conn
          |> assign(:schema, schema)
          |> assign(:object, object)

        conn
        |> put_flash(:info, "#{pretty(schema, :upcase, :singular)} created successfully.")
        |> redirect(to: construct_path(conn, :show))

      {:error, changeset} ->
        report(:warning, "Changeset Error")
        error_assigns = after_hooks[:error].(conn, params)

        conn
        |> put_status(422)
        |> render(
          CodeFundWeb.SharedView,
          "form_container.html",
          Enum.concat(
            error_assigns,
            schema: schema,
            conn: conn,
            action: :create,
            changeset: changeset
          )
        )
    end
  end

  def action(:show, schema, conn, %{"id" => id}, _after_hooks) do
    render(
      conn,
      "show.html",
      Keyword.new([
        {pretty(schema, :downcase, :singular) |> String.to_atom(), get!(schema, id)},
        {:schema, schema}
      ])
    )
  end

  def action(:edit, schema, conn, %{"id" => id}, _after_hooks) do
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

  def action(:update, schema, conn, %{"id" => id} = params, after_hooks) do
    object = get!(schema, id)
    current_user = current_user(conn)

    module_name(schema, :context)
    |> apply(:"update_#{pretty(schema, :downcase, :singular)}", [
      object,
      fetch_post_params(schema, params)
    ])
    |> case do
      {:ok, object} ->
        after_hooks[:success].(object, params)

        conn =
          conn
          |> assign(:schema, schema)
          |> assign(:object, object)

        conn
        |> put_flash(:info, "#{pretty(schema, :upcase, :singular)} updated successfully.")
        |> redirect(to: construct_path(conn, :show))

      {:error, changeset} ->
        report(:warning, "Changeset Error")
        after_hooks[:error].(conn, params)

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

  def action(:delete, schema, conn, %{"id" => id}, _after_hooks) do
    {:ok, object} =
      module_name(schema, :context)
      |> apply(:"delete_#{pretty(schema, :downcase, :singular)}", [get!(schema, id)])

    conn =
      conn
      |> assign(:schema, schema)
      |> assign(:object, object)

    conn
    |> put_flash(:info, "#{pretty(schema, :upcase, :singular)} deleted successfully.")
    |> redirect(to: construct_path(conn, :index))
  end

  @spec get!(String.t(), UUID.t()) :: struct
  defp get!(schema, id),
    do:
      apply(module_name(schema, :context), :"get_#{pretty(schema, :downcase, :singular)}!", [id])

  @spec current_user(%Plug.Conn{}) :: %CodeFund.Schema.User{}
  defp current_user(conn), do: conn.assigns.current_user

  @spec paginate(String.t()) :: atom
  defp paginate(schema), do: :"paginate_#{schema |> String.downcase() |> Inflex.pluralize()}"

  @spec fetch_object_params(String.t(), map) :: any()
  defp fetch_object_params(schema, params), do: params[schema |> String.downcase()]

  @spec fetch_post_params(String.t(), map) :: any()
  defp fetch_post_params(schema, params) do
    fetch_object_params(schema, params["params"])
  end
end
