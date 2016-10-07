port module Util.ImageData exposing (..)

import Json.Encode

type alias ColorData =
  { h : Int
  , s : Int
  , v : Int
  , id : String
  }

type alias ColorCommand =
  { command_type : String
  , payload : ColorData
  }

encodeCommand : ColorCommand -> String
encodeCommand record =
  let
    v =
      Json.Encode.object
      [ ("type",  Json.Encode.string <| record.command_type)
      , ("payload",  encodeColorData <| record.payload)
      ]
  in
    Json.Encode.encode 0 v

encodeColorData : ColorData -> Json.Encode.Value
encodeColorData record =
  Json.Encode.object
  [ ("h",  Json.Encode.int <| record.h)
  , ("s",  Json.Encode.int <| record.s)
  , ("v",  Json.Encode.int <| record.v)
  , ("id",  Json.Encode.string <| record.id)
  ]

port showColorPicker : String -> Cmd msg

port gotColor : (ColorData -> msg) -> Sub msg
