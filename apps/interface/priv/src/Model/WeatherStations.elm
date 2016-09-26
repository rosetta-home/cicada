module Model.WeatherStations exposing (..)

import Msg exposing (Msg)
import Json.Encode
import Json.Decode exposing ((:=))
-- elm-package install --yes circuithub/elm-json-extra
import Json.Decode.Extra exposing ((|:))

type alias Model =
  { devices: List WeatherStation
  }

model : Model
model =
  { devices = []
  }

type alias WeatherStation =
  { event_type : String
  , state : WeatherStationState
  , name : String
  , namespace : String
  , interface_pid : String
  , device_pid : String
  }

type alias WeatherStationStateWind =
  { speed : Float
  , direction : Float
  , gust : Float
  }

type alias WeatherStationStateSolar =
  { radiation : Float
  , intensity : Float
  }

type alias WeatherStationState =
  { outdoor_temperature : Float
  , indoor_temperature : Float
  , humidity : Float
  , pressure : Float
  , wind : WeatherStationStateWind
  , rain : Float
  , uv : Float
  , solar : WeatherStationStateSolar
  }

decodeWeatherStation : Json.Decode.Decoder WeatherStation
decodeWeatherStation =
  Json.Decode.succeed WeatherStation
    |: ("type" := Json.Decode.string)
    |: ("state" := decodeWeatherStationState)
    |: ("name" := Json.Decode.string)
    |: ("module" := Json.Decode.string)
    |: ("interface_pid" := Json.Decode.string)
    |: ("device_pid" := Json.Decode.string)

decodeWeatherStationStateWind : Json.Decode.Decoder WeatherStationStateWind
decodeWeatherStationStateWind =
  Json.Decode.succeed WeatherStationStateWind
  |: ("speed" := Json.Decode.float)
  |: ("direction" := Json.Decode.float)
  |: ("gust" := Json.Decode.float)

decodeWeatherStationStateSolar : Json.Decode.Decoder WeatherStationStateSolar
decodeWeatherStationStateSolar =
  Json.Decode.succeed WeatherStationStateSolar
  |: ("radiation" := Json.Decode.float)
  |: ("intensity" := Json.Decode.float)

decodeWeatherStationState : Json.Decode.Decoder WeatherStationState
decodeWeatherStationState =
  Json.Decode.succeed WeatherStationState
  |: ("outdoor_temperature" := Json.Decode.float)
  |: ("indoor_temperature" := Json.Decode.float)
  |: ("humidity" := Json.Decode.float)
  |: ("pressure" := Json.Decode.float)
  |: ("wind" := decodeWeatherStationStateWind)
  |: ("rain" := Json.Decode.float)
  |: ("uv" := Json.Decode.float)
  |: ("solar" := decodeWeatherStationStateSolar)
