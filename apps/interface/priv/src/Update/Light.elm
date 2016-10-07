module Update.Light exposing (..)

import Msg exposing(Msg)
import Model.Lights exposing (Model, LightInterface)
import Config exposing(eventServer)
import Util.ImageData exposing(ColorCommand, encodeCommand)
import WebSocket


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
    Msg.GotColor color->
      let
        cmd = ColorCommand "LightColor" color
      in
        ({model | devices = (List.map (\i ->
          if i.device.interface_pid == color.id then
            let
              d = i.device
              s = d.state
              hsbk = s.hsbk
              n_h = { hsbk | hue = color.h, saturation = color.s, brightness = color.v}
              n_s = {s | hsbk = n_h}
              n_d = {d | state = n_s }
            in
              { i | device = n_d }
          else
            i
        ) model.devices)}, WebSocket.send eventServer (cmd |> encodeCommand))
    _ -> (model, Cmd.none)
