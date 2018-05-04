defmodule Framework.Controller.AssignsTest do
  use ExUnit.Case
  import Framework.Controller.Assigns

  def stub(_arg, _another_arg) do
    true
  end

  describe "assigns/1" do
    test "it adds to the assigns list" do
      assert assigns(thing: "stuff") == [assigns: [thing: "stuff"]]
    end
  end

  describe "before_hook/2" do
    test "it adds to the before_hook list" do
      [before_hook: before_hook_function, after_hooks: []] = before_hook(&stub/2)
      ast = quote do: before_hook(&stub/2)

      assert ast ==
               {:before_hook,
                [
                  context: Framework.Controller.AssignsTest,
                  import: Framework.Controller.Assigns
                ],
                [
                  {:&, [],
                   [
                     {:/, [context: Framework.Controller.AssignsTest, import: Kernel],
                      [{:stub, [], Framework.Controller.AssignsTest}, 2]}
                   ]}
                ]}

      assert before_hook_function.("ok", "ok") == true
    end

    test "it raises if you call before_hook twice" do
      function_stub = (fn _one, _two -> true end).("ok", "test")

      assert_raise Framework.Controller.AssignsError,
                   ~r/before_hook already set on stub assigns/,
                   fn ->
                     before_hook(function_stub)
                     |> before_hook(function_stub)
                   end
    end
  end

  describe "inject_params/2" do
    test "it adds to the inject_params list" do
      [inject_params: inject_params_function, after_hooks: []] = inject_params(&stub/2)
      ast = quote do: inject_params(&stub/2)

      assert ast ==
               {:inject_params,
                [
                  context: Framework.Controller.AssignsTest,
                  import: Framework.Controller.Assigns
                ],
                [
                  {:&, [],
                   [
                     {:/, [context: Framework.Controller.AssignsTest, import: Kernel],
                      [{:stub, [], Framework.Controller.AssignsTest}, 2]}
                   ]}
                ]}

      assert inject_params_function.("ok", "ok") == true
    end

    test "it raises if you call inject_params twice" do
      function_stub = (fn _one, _two -> true end).("ok", "test")

      assert_raise Framework.Controller.AssignsError,
                   ~r/inject_params already set on stub assigns/,
                   fn ->
                     inject_params(function_stub)
                     |> inject_params(function_stub)
                   end
    end
  end

  describe "success/2" do
    test "it adds to the success list" do
      [after_hooks: [success: success_function]] = success(&stub/2)
      ast = quote do: success(&stub/2)

      assert ast ==
               {:success,
                [
                  context: Framework.Controller.AssignsTest,
                  import: Framework.Controller.Assigns
                ],
                [
                  {:&, [],
                   [
                     {:/, [context: Framework.Controller.AssignsTest, import: Kernel],
                      [{:stub, [], Framework.Controller.AssignsTest}, 2]}
                   ]}
                ]}

      assert success_function.("ok", "ok") == true
    end

    test "it raises if you call success twice" do
      function_stub = (fn _one, _two -> true end).("ok", "test")

      assert_raise Framework.Controller.AssignsError,
                   ~r/success already set on stub assigns/,
                   fn ->
                     success(function_stub)
                     |> success(function_stub)
                   end
    end
  end

  describe "error/2" do
    test "it adds to the error list" do
      [after_hooks: [error: error_function]] = error(&stub/2)
      ast = quote do: error(&stub/2)

      assert ast ==
               {:error,
                [
                  context: Framework.Controller.AssignsTest,
                  import: Framework.Controller.Assigns
                ],
                [
                  {:&, [],
                   [
                     {:/, [context: Framework.Controller.AssignsTest, import: Kernel],
                      [{:stub, [], Framework.Controller.AssignsTest}, 2]}
                   ]}
                ]}

      assert error_function.("ok", "ok") == true
    end

    test "it raises if you call error twice" do
      function_stub = (fn _one, _two -> true end).("ok", "test")

      assert_raise Framework.Controller.AssignsError, ~r/error already set on stub assigns/, fn ->
        error(function_stub)
        |> error(function_stub)
      end
    end
  end
end
