defmodule Cicada.VoiceControl.Client do
  use GenServer
  require Logger

  defmodule MoviHandler do
    use GenEvent
    require Logger

    def init do
        {:ok, []}
    end

    def handle_event(%Movi.Event{} = event, parent) do
        send(parent, event)
        {:ok, parent}
    end

    def handle_event(_other, parent) do
        {:ok, parent}
    end

  end

  defmodule Callback do
    defstruct phrase: "",
      id: nil,
      from: nil
  end

  defmodule State do
    defstruct callbacks: []
  end

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def add_handler(phrase, id) do
    GenServer.call(__MODULE__, {:add_handler, phrase, id})
  end

  def say(phrase) do
    Movi.Client.say phrase
  end

  def init(:ok) do
    Movi.Client.add_handler(MoviHandler)
    Movi.Client.threshold 50
    Movi.Client.volume 100
    Movi.Client.female
    Movi.Client.systemmessages "OFF"
    Movi.Client.responses "OFF"
    Movi.Client.beeps "OFF"
    Movi.Client.welcomemessage "OFF"
    Movi.Client.callsign "ROSETTA"
    Process.send_after(self, :train, 20000)
    {:ok, %State{}}
  end

  def handle_info(:train, state) do
    Movi.Client.trainsentences
    {:noreply, state}
  end

  def handle_call({:add_handler, phrase, id}, from, state) do
    Movi.Client.addsentence(phrase)
    cb = %Callback{
      phrase: String.upcase(phrase),
      id: id,
      from: from |> elem(0)
    }
    state = %State{ state | callbacks: [ cb | state.callbacks ]}
    Logger.info("Handler Added: #{inspect state}")
    {:reply, :ok, state}
  end

  def handle_info(%Movi.Event{code: 201} = event, state) do
    Logger.info("Phrase Recognized: #{inspect event}")
    Logger.info("Phrase: #{Enum.join(event.message, " ")}")
    Enum.join(event.message, " ") |> handle_callbacks(state.callbacks)
    {:noreply, state}
  end

  def handle_info(%Movi.Event{} = event, state) do
    Logger.info("Movi Event: #{inspect event}")
    {:noreply, state}
  end

  def handle_callbacks(phrase, callbacks) do
    callbacks |> Enum.each(fn(cb) ->
      case String.contains?(cb.phrase, phrase) do
        true ->
          Logger.info("CALLBACK: #{inspect cb}")
          send(cb.from, {:voice_callback, cb.id})
        false -> :ok
      end
    end)
  end

end
