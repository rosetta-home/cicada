import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode exposing (..)
import Json.Decode.Extra exposing ((|:))
import WebSocket

main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL
eventServer : String
eventServer =
  "ws://localhost:8081/ws?user_id=3894298374"

type alias Event =
  { namespace : String
  , event_type : EventType
  , interface_pid : String
  , device_pid : String
  , name : Maybe String
  }

type EventType
  = HVAC
  | Light
  | MediaPlayer
  | SmartMeter
  | WeatherStation
  | Unknown

event =
  succeed Event
    |: ("module" := string)
    |: (("type" := string) `andThen` decodeEventType)
    |: ("interface_pid" := string)
    |: ("device_pid" := string)
    |: (maybe ("name" := string))


decodeEventType : String -> Decoder EventType
decodeEventType event_type = succeed (eventType event_type)

eventType : String -> EventType
eventType event_type =
  case event_type of
    "hvac" -> HVAC
    "light" -> Light
    "media_player" -> MediaPlayer
    "smart_meter" -> SmartMeter
    "weather_station" -> WeatherStation
    _ -> Unknown


type alias Model =
  { events : List Event
  }

init : (Model, Cmd Msg)
init =
  (Model [], Cmd.none)

-- UPDATE

type Msg = NewMessage String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NewMessage str ->
      case Debug.log "event" (decodeString event str) of
        Ok evt -> ({model | events = evt :: model.events}, Cmd.none)
        Err _ -> (model, Cmd.none)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen eventServer NewMessage

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ div [] (List.map viewMessage model.events)
    ]

viewMessage : Event -> Html Msg
viewMessage msg =
  div [] [ text (toString msg.event_type ++ ": " ++ msg.interface_pid) ]
