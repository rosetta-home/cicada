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
    , device_pid : String
    }

type alias MediaPlayerStateReceiver_statusStatusVolume =
    { stepInterval : Float
    , muted : Bool
    , level : Int
    , controlType : String
    }

type alias MediaPlayerStateReceiver_statusStatus =
    { volume : MediaPlayerStateReceiver_statusStatusVolume
    , applications : String
    }

type alias MediaPlayerStateReceiver_status =
    { status_type : String
    , status : MediaPlayerStateReceiver_statusStatus
    , requestId : Int
    }

type alias MediaPlayerStateMedia_status =
    {
    }

type alias MediaPlayerState =
    { ssl : String
    , session : String
    , request_id : Int
    , receiver_status : String
    , media_status : String
    , media_session : String
    , ip : String
    , destination_id : String
    }

decodeMediaPlayer : Json.Decode.Decoder MediaPlayer
decodeMediaPlayer =
    Json.Decode.succeed MediaPlayer
        |: ("type" := Json.Decode.string)
        |: ("state" := decodeMediaPlayerState)
        |: ("name" := Json.Decode.string)
        |: ("module" := Json.Decode.string)
        |: ("interface_pid" := Json.Decode.string)
        |: ("device_pid" := Json.Decode.string)

decodeMediaPlayerStateReceiver_statusStatusVolume : Json.Decode.Decoder MediaPlayerStateReceiver_statusStatusVolume
decodeMediaPlayerStateReceiver_statusStatusVolume =
    Json.Decode.succeed MediaPlayerStateReceiver_statusStatusVolume
        |: ("stepInterval" := Json.Decode.float)
        |: ("muted" := Json.Decode.bool)
        |: ("level" := Json.Decode.int)
        |: ("controlType" := Json.Decode.string)

decodeMediaPlayerStateReceiver_statusStatus : Json.Decode.Decoder MediaPlayerStateReceiver_statusStatus
decodeMediaPlayerStateReceiver_statusStatus =
    Json.Decode.succeed MediaPlayerStateReceiver_statusStatus
        |: ("volume" := decodeMediaPlayerStateReceiver_statusStatusVolume)
        |: ("applications" := Json.Decode.string)

decodeMediaPlayerStateReceiver_status : Json.Decode.Decoder MediaPlayerStateReceiver_status
decodeMediaPlayerStateReceiver_status =
    Json.Decode.succeed MediaPlayerStateReceiver_status
        |: ("type" := Json.Decode.string)
        |: ("status" := decodeMediaPlayerStateReceiver_statusStatus)
        |: ("requestId" := Json.Decode.int)


decodeMediaPlayerState : Json.Decode.Decoder MediaPlayerState
decodeMediaPlayerState =
    Json.Decode.succeed MediaPlayerState
        |: ("ssl" := Json.Decode.string)
        |: ("session" := Json.Decode.string)
        |: ("request_id" := Json.Decode.int)
        |: ("receiver_status" := Json.Decode.string)
        |: ("media_status" := Json.Decode.string)
        |: ("media_session" := Json.Decode.string)
        |: ("ip" := Json.Decode.string)
        |: ("destination_id" := Json.Decode.string)

encodeMediaPlayer : MediaPlayer -> Json.Encode.Value
encodeMediaPlayer record =
    Json.Encode.object
        [ ("type",  Json.Encode.string <| record.event_type)
        , ("state",  encodeMediaPlayerState <| record.state)
        , ("name",  Json.Encode.string <| record.name)
        , ("module",  Json.Encode.string <| record.namespace)
        , ("interface_pid",  Json.Encode.string <| record.interface_pid)
        , ("device_pid",  Json.Encode.string <| record.device_pid)
        ]

encodeMediaPlayerStateReceiver_statusStatusVolume : MediaPlayerStateReceiver_statusStatusVolume -> Json.Encode.Value
encodeMediaPlayerStateReceiver_statusStatusVolume record =
    Json.Encode.object
        [ ("stepInterval",  Json.Encode.float <| record.stepInterval)
        , ("muted",  Json.Encode.bool <| record.muted)
        , ("level",  Json.Encode.int <| record.level)
        , ("controlType",  Json.Encode.string <| record.controlType)
        ]

encodeMediaPlayerStateReceiver_statusStatus : MediaPlayerStateReceiver_statusStatus -> Json.Encode.Value
encodeMediaPlayerStateReceiver_statusStatus record =
    Json.Encode.object
        [ ("volume",  encodeMediaPlayerStateReceiver_statusStatusVolume <| record.volume)
        , ("applications",  Json.Encode.string <| record.applications)
        ]

encodeMediaPlayerStateReceiver_status : MediaPlayerStateReceiver_status -> Json.Encode.Value
encodeMediaPlayerStateReceiver_status record =
    Json.Encode.object
        [ ("type",  Json.Encode.string <| record.status_type)
        , ("status",  encodeMediaPlayerStateReceiver_statusStatus <| record.status)
        , ("requestId",  Json.Encode.int <| record.requestId)
        ]

encodeMediaPlayerState : MediaPlayerState -> Json.Encode.Value
encodeMediaPlayerState record =
    Json.Encode.object
        [ ("ssl",  Json.Encode.string <| record.ssl)
        , ("session",  Json.Encode.string <| record.session)
        , ("request_id",  Json.Encode.int <| record.request_id)
        , ("receiver_status",  Json.Encode.string <| record.receiver_status)
        , ("media_status",  Json.Encode.string <| record.media_status)
        , ("media_session",  Json.Encode.string <| record.media_session)
        , ("ip",  Json.Encode.string <| record.ip)
        , ("destination_id",  Json.Encode.string <| record.destination_id)
        ]
