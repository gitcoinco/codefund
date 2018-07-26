defmodule CodeFund.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(CodeFund.Repo, []),
      # Start the endpoint when the application starts
      supervisor(CodeFundWeb.Endpoint, []),
      # Start your own worker by calling: CodeFund.Worker.start_link(arg1, arg2, arg3)
      # worker(CodeFund.Worker, [arg1, arg2, arg3]),
      worker(CodeFundWeb.Notificator, [], restart: :transient),
      :poolboy.child_spec(:worker, Application.get_env(:redix, :pool), restart: :transient)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CodeFund.Supervisor]

    :ok = :error_logger.add_report_handler(Sentry.Logger)

    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CodeFundWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
