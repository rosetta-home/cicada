module Model.MediaPlayers exposing (..)

import Json.Encode
import Json.Decode exposing ((:=))
-- elm-package install --yes circuithub/elm-json-extra
import Json.Decode.Extra exposing ((|:))
import Dict exposing (Dict)

type alias Model =
  { devices: List MediaPlayer
  , history: Dict String (List MediaPlayerState)
  }

model : Model
model =
  { devices = []
  , history = Dict.empty
  }

type alias MediaPlayer =
    { event_type : String
    , state : MediaPlayerState
    , name : String
    , namespace : String
    , interface_pid : String
    , device_pid : Maybe String
    }

type alias MediaPlayerState =
    { ip : String
    , current_time : Float
    , content_id: Int
    , content_type: String
    , duration: Maybe Float
    , autoplay: Bool
    , image: MediaPlayerStateImage
    , title: String
    , subtitle: Maybe String
    , volume: Int
    , status: String
    , idle: Bool
    , app_name: String
    , id: String
    }


type alias MediaPlayerStateImage =
  { width: Int
  ,  height: Int
  ,  url: String
  }

decodeMediaPlayer : Json.Decode.Decoder MediaPlayer
decodeMediaPlayer =
    Json.Decode.succeed MediaPlayer
        |: ("type" := Json.Decode.string)
        |: ("state" := decodeMediaPlayerState)
        |: ("name" := Json.Decode.string)
        |: ("module" := Json.Decode.string)
        |: ("interface_pid" := Json.Decode.string)
        |: (Json.Decode.maybe ("device_pid" := Json.Decode.string))

decodeMediaPlayerState : Json.Decode.Decoder MediaPlayerState
decodeMediaPlayerState =
    Json.Decode.succeed MediaPlayerState
        |: ("ip" := Json.Decode.string)
        |: ("current_time" := Json.Decode.float)
        |: ("content_id" := Json.Decode.int)
        |: ("content_type" := Json.Decode.string)
        |: (Json.Decode.maybe ("duration" := Json.Decode.float))
        |: ("autoplay" := Json.Decode.bool)
        |: ("image" := decodeMediaPlayerImage)
        |: ("title" := Json.Decode.string)
        |: (Json.Decode.maybe ("subtitle" := Json.Decode.string))
        |: ("volume" := Json.Decode.int)
        |: ("status" := Json.Decode.string)
        |: ("idle" := Json.Decode.bool)
        |: ("app_name" := Json.Decode.string)
        |: ("id" := Json.Decode.string)

decodeMediaPlayerImage : Json.Decode.Decoder MediaPlayerStateImage
decodeMediaPlayerImage =
    Json.Decode.succeed MediaPlayerStateImage
        |: ("width" := Json.Decode.int)
        |: ("height" := Json.Decode.int)
        |: ("url" := Json.Decode.string)
