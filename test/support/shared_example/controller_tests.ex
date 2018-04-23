defmodule SharedExample.ControllerTests do
  import CodeFund.Factory

  def stub_users do
    %{
      developer: insert(:user, roles: ["developer"]),
      sponsor: insert(:user, roles: ["sponsor"]),
      admin: insert(:user, roles: ["admin"])
    }
  end

  defmacro authenticated(endpoint, method) do
    quote bind_quoted: [endpoint: endpoint], unquote: true do
      test "#{endpoint} redirects to sessions/new if not signed in", context do
        method = unquote(method)
        conn = method.(context.conn, context)
        assert redirected_to(conn, 302) == "/sessions/new"
      end
    end
  end

  defmacro owned_non_admin(endpoint, method) do
    quote bind_quoted: [endpoint: endpoint], unquote: true do
      test "#{endpoint} redirects to dashboard if signed as non_admin and the object is not owned by the user",
           context do
        conn = assign(context.conn, :current_user, context.users.developer)
        method = unquote(method)
        conn = method.(conn, context)
        assert redirected_to(conn, 302) == "/dashboard"
        assert get_flash(conn, :error) == "You are not authorized to view this page."
      end
    end
  end

  defmacro owned_admin(endpoint, method) do
    quote bind_quoted: [endpoint: endpoint], unquote: true do
      test "#{endpoint} allows admins to pass through", context do
        conn = assign(context.conn, :current_user, context.users.admin)
        method = unquote(method)
        conn = method.(conn, context)

        desired_conn_status =
          case conn.method == "PATCH" do
            true -> 302
            false -> 200
          end

        assert conn.status == desired_conn_status
      end
    end
  end

  defmacro auth_as(endpoint, method, role) do
    failing_role =
      case role do
        :admin -> :sponsor
        :sponsor -> :developer
      end

    quote bind_quoted: [endpoint: endpoint, role: role, failing_role: failing_role],
          unquote: true do
      test "#{endpoint} redirects to /dashboard if user is not at least a #{role}", context do
        conn =
          assign(context.conn, :current_user, context.users |> Map.get(unquote(failing_role)))

        method = unquote(method)
        conn = method.(conn, context)
        assert redirected_to(conn, 302) == "/dashboard"
        assert get_flash(conn, :error) == "You are not authorized to view this page."
      end
    end
  end

  defmacro behaves_like(method, [:authenticated, :owned_unless_admin], endpoint) do
    quote bind_quoted: [endpoint: endpoint], unquote: true do
      authenticated(endpoint, unquote(method))
      owned_admin(endpoint, unquote(method))
      owned_non_admin(endpoint, unquote(method))
    end
  end

  defmacro behaves_like(method, [:authenticated], endpoint) do
    quote bind_quoted: [endpoint: endpoint], unquote: true do
      authenticated(endpoint, unquote(method))
    end
  end

  defmacro behaves_like(method, [:authenticated, :admin], endpoint) do
    quote bind_quoted: [endpoint: endpoint], unquote: true do
      authenticated(endpoint, unquote(method))
      auth_as(endpoint, unquote(method), :sponsor)
      auth_as(endpoint, unquote(method), :admin)
    end
  end

  defmacro behaves_like(method, [:authenticated, :sponsor], endpoint) do
    quote bind_quoted: [endpoint: endpoint], unquote: true do
      authenticated(endpoint, unquote(method))
      auth_as(endpoint, unquote(method), :sponsor)
    end
  end
end
