module Model.Lights exposing (..)

import Msg exposing (Msg)
import Json.Encode
import Json.Decode exposing ((:=))
-- elm-package install --yes circuithub/elm-json-extra
import Json.Decode.Extra exposing ((|:))

type alias Model =
  { devices: List Light
  }

model : Model
model =
  { devices = []
  }

type alias Light =
  { event_type : String
  , state : LightState
  , name : String
  , namespace : String
  , interface_pid : String
  , device_pid : String
  }

type alias LightStateHsbk =
  { saturation : Int
  , kelvin : Int
  , hue : Int
  , brightness : Int
  }

type alias LightState =
  { tx : Int
  , signal : Float
  , rx : Int
  , power : Int
  , ip_port : Int
  , location : String
  , label : String
  , id : String
  , hsbk : LightStateHsbk
  , host : String
  , group : String
  }

decodeLight : Json.Decode.Decoder Light
decodeLight =
  Json.Decode.succeed Light
    |: ("type" := Json.Decode.string)
    |: ("state" := decodeLightState)
    |: ("name" := Json.Decode.string)
    |: ("module" := Json.Decode.string)
    |: ("interface_pid" := Json.Decode.string)
    |: ("device_pid" := Json.Decode.string)

decodeLightStateHsbk : Json.Decode.Decoder LightStateHsbk
decodeLightStateHsbk =
  Json.Decode.succeed LightStateHsbk
  |: ("saturation" := Json.Decode.int)
  |: ("kelvin" := Json.Decode.int)
  |: ("hue" := Json.Decode.int)
  |: ("brightness" := Json.Decode.int)

decodeLightState : Json.Decode.Decoder LightState
decodeLightState =
  Json.Decode.succeed LightState
  |: ("tx" := Json.Decode.int)
  |: ("signal" := Json.Decode.float)
  |: ("rx" := Json.Decode.int)
  |: ("power" := Json.Decode.int)
  |: ("port" := Json.Decode.int)
  |: ("location" := Json.Decode.string)
  |: ("label" := Json.Decode.string)
  |: ("id" := Json.Decode.string)
  |: ("hsbk" := decodeLightStateHsbk)
  |: ("host" := Json.Decode.string)
  |: ("group" := Json.Decode.string)

encodeLight : Light -> Json.Encode.Value
encodeLight record =
  Json.Encode.object
  [ ("type",  Json.Encode.string <| record.event_type)
  , ("state",  encodeLightState <| record.state)
  , ("name",  Json.Encode.string <| record.name)
  , ("module",  Json.Encode.string <| record.namespace)
  , ("interface_pid",  Json.Encode.string <| record.interface_pid)
  , ("device_pid",  Json.Encode.string <| record.device_pid)
  ]

encodeLightStateHsbk : LightStateHsbk -> Json.Encode.Value
encodeLightStateHsbk record =
  Json.Encode.object
  [ ("saturation",  Json.Encode.int <| record.saturation)
  , ("kelvin",  Json.Encode.int <| record.kelvin)
  , ("hue",  Json.Encode.int <| record.hue)
  , ("brightness",  Json.Encode.int <| record.brightness)
  ]

encodeLightState : LightState -> Json.Encode.Value
encodeLightState record =
  Json.Encode.object
  [ ("tx",  Json.Encode.int <| record.tx)
  , ("signal",  Json.Encode.float <| record.signal)
  , ("rx",  Json.Encode.int <| record.rx)
  , ("power",  Json.Encode.int <| record.power)
  , ("port",  Json.Encode.int <| record.ip_port)
  , ("location",  Json.Encode.string <| record.location)
  , ("label",  Json.Encode.string <| record.label)
  , ("id",  Json.Encode.string <| record.id)
  , ("hsbk",  encodeLightStateHsbk <| record.hsbk)
  , ("host",  Json.Encode.string <| record.host)
  , ("group",  Json.Encode.string <| record.group)
  ]
