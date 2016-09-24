module Model.MediaPlayers exposing (..)

import Json.Encode
import Json.Decode exposing ((:=))
-- elm-package install --yes circuithub/elm-json-extra
import Json.Decode.Extra exposing ((|:))

type alias Model =
  { devices: List MediaPlayer
  }

model : Model
model =
  { devices = []
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
    { receiver_status : MediaPlayerStateReceiverStatus
    , media_status : MediaPlayerStateMediaStatus
    , ip : String
    }

type alias MediaPlayerStateReceiverStatus =
    { volume : Int
    , applications : List MediaPlayerStateApplication
    }

type alias MediaPlayerStateMediaStatus =
    { items : List MediaPlayerStateItem
    , current_time : Float
    }

type alias MediaPlayerStateItem =
  { autoplay: Bool
  ,  id: Int
  ,  content_id: String
  ,  content_type: String
  ,  item_type: Maybe String
  ,  duration: Maybe Float
  ,  images: List MediaPlayerStateImage
  ,  title: String
  ,  subtitle: Maybe String
  }

type alias MediaPlayerStateApplication =
  { id: String
  ,  name: String
  ,  idle: Bool
  ,  session_id: String
  ,  status: String
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

decodeMediaPlayerItem : Json.Decode.Decoder MediaPlayerStateItem
decodeMediaPlayerItem =
    Json.Decode.succeed MediaPlayerStateItem
        |: ("autoplay" := Json.Decode.bool)
        |: ("id" := Json.Decode.int)
        |: ("content_id" := Json.Decode.string)
        |: ("content_type" := Json.Decode.string)
        |: (Json.Decode.maybe ("type" := Json.Decode.string))
        |: (Json.Decode.maybe ("duration" := Json.Decode.float))
        |: ("images" := Json.Decode.list decodeMediaPlayerImage)
        |: ("title" := Json.Decode.string)
        |: (Json.Decode.maybe ("subtitle" := Json.Decode.string))

decodeMediaPlayerApplication : Json.Decode.Decoder MediaPlayerStateApplication
decodeMediaPlayerApplication =
    Json.Decode.succeed MediaPlayerStateApplication
        |: ("id" := Json.Decode.string)
        |: ("name" := Json.Decode.string)
        |: ("idle" := Json.Decode.bool)
        |: ("session_id" := Json.Decode.string)
        |: ("status" := Json.Decode.string)

decodeMediaPlayerImage : Json.Decode.Decoder MediaPlayerStateImage
decodeMediaPlayerImage =
    Json.Decode.succeed MediaPlayerStateImage
        |: ("width" := Json.Decode.int)
        |: ("height" := Json.Decode.int)
        |: ("url" := Json.Decode.string)

decodeMediaPlayerStateReceiverStatus : Json.Decode.Decoder MediaPlayerStateReceiverStatus
decodeMediaPlayerStateReceiverStatus =
    Json.Decode.succeed MediaPlayerStateReceiverStatus
        |: ("volume" := Json.Decode.int)
        |: ("applications" := Json.Decode.list decodeMediaPlayerApplication)



decodeMediaPlayerStateMediaStatus : Json.Decode.Decoder MediaPlayerStateMediaStatus
decodeMediaPlayerStateMediaStatus =
    Json.Decode.succeed MediaPlayerStateMediaStatus
        |: ("items" := Json.Decode.list decodeMediaPlayerItem)
        |: ("current_time" := Json.Decode.float)

decodeMediaPlayerState : Json.Decode.Decoder MediaPlayerState
decodeMediaPlayerState =
    Json.Decode.succeed MediaPlayerState
        |: ("receiver_status" := decodeMediaPlayerStateReceiverStatus)
        |: ("media_status" := decodeMediaPlayerStateMediaStatus)
        |: ("ip" := Json.Decode.string)
