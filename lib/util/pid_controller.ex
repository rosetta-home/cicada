defmodule Cicada.Util.PIDController do
  use GenServer
  require Logger

  @sample_rate Application.get_env(:core, :sample_rate)

  def init(%{trace: trace}) do
    {:ok, %{
      sample_rate: @sample_rate,
      last_input: 0,
      integrative_term: 0,
      setpoint: 0,
      process_name: Process.info(self())[:registered_name],
      last_timestamp: nil,
      trace: trace
    }}
  end

  def handle_call({:configure, kp, ki, kd, minimum_output, maximum_output}, _from, state) do
    sample_rate_in_seconds = @sample_rate / 1000
    new_state              = %{
      raw_kp: kp,
      raw_ki: ki,
      raw_kd: kd,
      kp: kp,
      ki: ki * sample_rate_in_seconds,
      kd: kd / sample_rate_in_seconds,
      minimum_output: minimum_output,
      maximum_output: maximum_output
    }
    {:reply, :ok, Map.merge(state, new_state)}
  end

  def handle_call({:update_setpoint, value}, _from, state) do
    {:reply, :ok, %{state | setpoint: value}}
  end

  def handle_call({:compute, input}, _from, state) do
    error             = state[:setpoint] - input
    proportional_term = state[:kp] * error
    integrative_term  = state[:integrative_term] + state[:ki] * error
    derivative_term   = state[:kd] * (input - state[:last_input])

    integrative_term = min(integrative_term, state[:maximum_output])
    integrative_term = max(integrative_term, state[:minimum_output])

    output = proportional_term + integrative_term - derivative_term
    output = min(output, state[:maximum_output])
    output = max(output, state[:minimum_output])

    trace(state, error, output, proportional_term, integrative_term, derivative_term)

    {:reply, {:ok, output}, Map.merge(state, %{
      integrative_term: integrative_term,
      last_input: input
    })}
  end

  def handle_cast({:tune, %{kp: kp, ki: ki, kd: kd}}, state) do
    sample_rate_in_seconds = state[:sample_rate] / 1000
    new_state = %{
      raw_kp: kp,
      raw_ki: ki,
      raw_kd: kd,
      kp: kp,
      ki: ki * sample_rate_in_seconds,
      kd: kd / sample_rate_in_seconds
    }
    Logger.info "#{__MODULE__} (#{state[:process_name]}) tuned to kp: #{kp}, ki: #{ki}, kd: #{kd}..."
    {:noreply, Map.merge(state, new_state)}
  end

  def handle_cast({:tune, %{kp: kp}}, state) do
    new_state = %{
      kp: kp,
      raw_kp: kp
    }
    Logger.info "#{__MODULE__} (#{state[:process_name]}) tuned to kp: #{kp}..."
    {:noreply, Map.merge(state, new_state)}
  end

  def handle_cast({:tune, %{ki: ki}}, state) do
    sample_rate_in_seconds = state[:sample_rate] / 1000
    new_state = %{
      ki: ki * sample_rate_in_seconds,
      raw_ki: ki
    }
    Logger.info "#{__MODULE__} (#{state[:process_name]}) tuned to ki: #{ki}..."
    {:noreply, Map.merge(state, new_state)}
  end

  def handle_cast({:tune, %{kd: kd}}, state) do
    sample_rate_in_seconds = state[:sample_rate] / 1000
    new_state = %{
      kd: kd / sample_rate_in_seconds,
      raw_kd: kd
    }
    Logger.info "#{__MODULE__} (#{state[:process_name]}) tuned to kd: #{kd}..."
    {:noreply, Map.merge(state, new_state)}
  end

  def handle_cast({:reset, _}, state) do
    new_state = %{
      integrative_term: 0
    }
    Logger.info "#{__MODULE__} (#{state[:process_name]}) reinitialized..."
    {:noreply, Map.merge(state, new_state)}
  end

  defp trace(state, error, output, proportional_term, integrative_term, derivative_term) do
    if state[:trace] do
      data = %{
        name: Process.info(self())[:registered_name],
        kp: state[:raw_kp],
        ki: state[:raw_ki],
        kd: state[:raw_kd],
        proportional_term: proportional_term,
        integrative_term: integrative_term,
        derivative_term: derivative_term,
        error: error,
        output: output
      }
    end
  end

  def start_link(name, trace \\ true) do
    Logger.debug "Starting #{__MODULE__}..."
    GenServer.start_link(__MODULE__, %{trace: trace}, name: name)
  end

  def update_setpoint(setpoint, pid) do
    GenServer.call(pid, {:update_setpoint, setpoint})
  end

  def compute(input, pid) do
    GenServer.call(pid, {:compute, input})
  end

  def configure(configuration, pid) do
    GenServer.call(pid, Tuple.insert_at(configuration, 0, :configure))
  end
end
