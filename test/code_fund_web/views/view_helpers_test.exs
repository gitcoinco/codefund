defmodule CodeFundWeb.ViewHelpersTest do
  import CodeFundWeb.ViewHelpers
  use ExUnit.Case

  setup do
    text = "some text that will get trimmed"
    {:ok, %{text: text}}
  end

  test "truncate/2 trims text if its over the specified length", %{text: text} do
    assert truncate(text, 9) == "some text..."
  end

  test "truncate/2 trims trailing whitespace prior to trimming", %{text: text} do
    assert truncate(text, 10) == "some text..."
  end

  test "truncate/2 returns text untouched if it is below the specified length", %{text: text} do
    assert truncate(text, 100) == text
  end

  test "truncate/3 allows you to set the trailing text if it is trimmed", %{text: text} do
    assert truncate(text, 9, "***") == "some text***"
  end
end
