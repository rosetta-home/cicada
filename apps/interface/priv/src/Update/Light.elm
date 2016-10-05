module Update.Light exposing (..)

import Msg exposing(Msg)
import Model.Lights exposing (Model, LightInterface)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Msg.ToggleLight light ->
      ({model | devices = (List.map (\i ->
        if i.device.interface_pid == light.device.interface_pid then
          let
            test = Debug.log "Light toggle" ({ i | on = (not i.on) })
          in
            test
        else
          i
      ) model.devices)}, Cmd.none)
    _ -> (model, Cmd.none)
