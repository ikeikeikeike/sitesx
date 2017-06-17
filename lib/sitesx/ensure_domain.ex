defmodule Sitesx.EnsureDomain do
  @moduledoc """
  Periocially ensures dns record to the Database.

  ## Example

      config :sitesx
        ensure_domain_interval: 5_000  # Default: 600_000 milliseconds (if want disable, set 0 number)

  ## Database

      postgres@(none):dbname_dev> select * from sitesx;
      +------+--------------+-------+----------------------------+----------------------------+
      |   id | name         | dns   | inserted_at                | updated_at                 |
      |------+--------------+-------+----------------------------+----------------------------|
      |    1 | www          | True  | 2017-04-18 03:14:29.984272 | 2017-04-18 03:14:30.004545 |
      |    2 | subdomain2   | True  | 2017-04-19 03:49:41.532552 | 2017-04-19 03:49:41.532607 |
      |    3 | subdomain3   | False | 2017-04-19 09:22:15.460342 | 2017-04-19 09:22:15.472465 |
      |    4 | subdomain4   | True  | 2017-04-19 10:25:25.218343 | 2017-04-19 10:25:25.218349 |
      +------+--------------+-------+----------------------------+----------------------------+
  """
  use GenServer

  def start_link, do: start_link([])

  def start_link(state, _opts \\ []) do
    state = Enum.into(state, %{})

    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @doc """
  Reset the purge timer.
  """
  def reset_timer! do
    GenServer.call(__MODULE__, :reset_timer)
  end

  @doc """
  Manually trigger a ensure dns records.
  Also resets the current timer.
  """
  def purge! do
    GenServer.call(__MODULE__, :ensure_domain)
  end

  def init(state) do
    {:ok, reset_state_timer!(state)}
  end

  def handle_call(:reset_timer, _from, state) do
    {:reply, :ok, reset_state_timer!(state)}
  end

  def handle_call(:ensure_domain, _from, state) do
    {:reply, :ok, ensure_domain!(state)}
  end

  def handle_info(:ensure_domain, state) do
    {:noreply, ensure_domain!(state)}
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  defp ensure_domain!(state) do
    case interval() do
      msec when is_number(msec) and msec > 0 ->
        Sitesx.Q.ensure_domains
        reset_state_timer!(state)
      _ ->
        :do_nothing
    end
  end

  defp reset_state_timer!(state) do
    if state[:timer] do
      Process.cancel_timer(state.timer)
    end

    timer = Process.send_after(self(), :ensure_domain, interval())
    Map.merge(state, %{timer: timer})
  end

  defp interval do
    :sitesx
    |> Application.get_env(:ensure_domain_interval)
    |> Kernel.||(300_000)
  end
end
