defmodule CodeSponsor.PageControllerTest do
  use CodeSponsorWeb.ConnCase

  describe "PageController" do
    test "index" do
      conn = get build_conn(), "/"
      assert html_response(conn,200)
    end
  end
end
