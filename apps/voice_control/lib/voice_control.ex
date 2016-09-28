defmodule VoiceControl do
  use Application

  def start(_type, _opts) do
    VoiceControl.Supervisor.start_link
  end

end
