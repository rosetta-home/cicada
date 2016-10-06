module Util.MouseEvents exposing (..)

import Html
import Json.Decode as Decode exposing ((:=))
import DOM exposing (Rectangle)
import Html.Events exposing (..)

type alias Position =
  { x : Int, y : Int }

type alias MouseEvent =
  { clientPos : Position
  , targetPos : Position
  }

relPos : MouseEvent -> Position
relPos ev =
  Position (ev.clientPos.x - ev.targetPos.x) (ev.clientPos.y - ev.targetPos.y)

mouseEvent : Int -> Int -> Rectangle -> MouseEvent
mouseEvent clientX clientY target =
  { clientPos = Position clientX clientY
  , targetPos = Position (truncate target.left) (truncate target.top)
  }

mouseEventDecoder : Decode.Decoder MouseEvent
mouseEventDecoder =
  Decode.object3
    mouseEvent
    ("clientX" := Decode.int)
    ("clientY" := Decode.int)
    ("target" := DOM.boundingClientRect)

onClick : (MouseEvent -> msg) -> Html.Attribute msg
onClick target =
  on "click" (Decode.map target mouseEventDecoder)

test : msg -> Html.Attribute msg
test msg =
  on "click" (Decode.succeed msg)
