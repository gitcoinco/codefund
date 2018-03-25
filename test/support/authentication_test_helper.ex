defmodule CodeSponsor.AuthenticationTestHelpers do
  use Phoenix.ConnTest
  import CodeSponsor.Factory

  #when given a connection to authenticate create a user call auth witht user and conn
  def authenticate(conn) do
    user = insert(:user)
    conn
    |> authenticate(user)
  end

  def authenticate(conn, user) do
    conn = assign conn, :current_user, user
  end

end
