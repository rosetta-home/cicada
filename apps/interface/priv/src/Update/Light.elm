import Msg.Light as Msg
import Model.Light exposing (Light)

update : Msg -> Light -> (Light, Cmd Msg)
update msg model =
  case msg of
    Msg.Select item ->
      ( { model | selected = Just item }
      , Cmd.none
      )
