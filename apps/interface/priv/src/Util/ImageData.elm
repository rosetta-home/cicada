port module Util.ImageData exposing (..)

import Util.MouseEvents exposing (MouseEvent)

port getColor : MouseEvent -> Cmd msg

port gotColor : (String -> msg) -> Sub msg
