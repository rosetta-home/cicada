module Model.HVAC exposing (..)

import Msg exposing (Msg)
import Json.Encode
import Json.Decode exposing ((:=))
-- elm-package install --yes circuithub/elm-json-extra
import Json.Decode.Extra exposing ((|:))
import Dict exposing (Dict)

type alias Model =
  { devices: List HVAC
  , history: Dict String (List HVACState)
  }

model : Model
model =
  { devices = []
  , history = Dict.empty
  }

type alias HVAC =
    { event_type : String
    , state : HVACState
    , name : String
    , namespace : String
    , interface_pid : String
    , device_pid : String
    }

type alias HVACState =
    { temporary_target_heat : Float
    , temporary_target_cool : Float
    , temperature : Float
    , state : String
    , mode : String
    , fan_state : String
    , fan_mode : String
    }

decodeHVAC : Json.Decode.Decoder HVAC
decodeHVAC =
    Json.Decode.succeed HVAC
        |: ("type" := Json.Decode.string)
        |: ("state" := decodeHVACState)
        |: ("name" := Json.Decode.string)
        |: ("module" := Json.Decode.string)
        |: ("interface_pid" := Json.Decode.string)
        |: ("device_pid" := Json.Decode.string)

decodeHVACState : Json.Decode.Decoder HVACState
decodeHVACState =
    Json.Decode.succeed HVACState
        |: ("temporary_target_heat" := Json.Decode.float)
        |: ("temporary_target_cool" := Json.Decode.float)
        |: ("temperature" := Json.Decode.float)
        |: ("state" := Json.Decode.string)
        |: ("mode" := Json.Decode.string)
        |: ("fan_state" := Json.Decode.string)
        |: ("fan_mode" := Json.Decode.string)

encodeHVAC : HVAC -> Json.Encode.Value
encodeHVAC record =
    Json.Encode.object
        [ ("type",  Json.Encode.string <| record.event_type)
        , ("state",  encodeHVACState <| record.state)
        , ("name",  Json.Encode.string <| record.name)
        , ("module",  Json.Encode.string <| record.namespace)
        , ("interface_pid",  Json.Encode.string <| record.interface_pid)
        , ("device_pid",  Json.Encode.string <| record.device_pid)
        ]

encodeHVACState : HVACState -> Json.Encode.Value
encodeHVACState record =
    Json.Encode.object
        [ ("temporary_target_heat",  Json.Encode.float <| record.temporary_target_heat)
        , ("temporary_target_cool",  Json.Encode.float <| record.temporary_target_cool)
        , ("temperature",  Json.Encode.float <| record.temperature)
        , ("state",  Json.Encode.string <| record.state)
        , ("mode",  Json.Encode.string <| record.mode)
        , ("fan_state",  Json.Encode.string <| record.fan_state)
        , ("fan_mode",  Json.Encode.string <| record.fan_mode)
        ]