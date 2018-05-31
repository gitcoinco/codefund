defmodule Framework.Worker do
  def enqueue_worker(worker, args) do
    Mix.env()
    |> run_worker(worker, args)
  end

  defp run_worker(:test, worker, args), do: apply(worker, :perform, args)
  defp run_worker(_mix_env, worker, args), do: Exq.enqueue(Exq, "cs_low", worker, args)
end
