import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode exposing (..)
import Json.Decode.Extra exposing ((|:))
import MediaPlayer exposing (MediaPlayer, decodeMediaPlayer)
import Light exposing (Light, decodeLight)
import WebSocket
import Debug

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

type alias Model =
  { lights : List Light
  , media_players : List MediaPlayer
  }

type alias Event =
  { event_type : EventType
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
    |: (("type" := string) `andThen` decodeEventType)


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

init : (Model, Cmd Msg)
init =
  (Model [] [], Cmd.none)

-- UPDATE

type Msg = NewMessage String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NewMessage str ->
      case decodeString event str of
        Ok evt ->
          case evt.event_type of
            Light ->
              case Debug.log "Light" (decodeString decodeLight str) of
                Ok light -> ({model | lights = light :: model.lights}, Cmd.none)
                Err _ -> (model, Cmd.none)
            MediaPlayer ->
              case Debug.log "MediaPlayer" (decodeString decodeMediaPlayer str) of
                Ok media_player -> ({model | media_players = media_player :: model.media_players}, Cmd.none)
                Err _ -> (model, Cmd.none)
            _ -> (model, Cmd.none)

        Err _ -> (model, Cmd.none)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen eventServer NewMessage

-- VIEW

view : Model -> Html Msg
view model =
  div []
  [ div [] (List.map viewLight model.lights)
    , div [] (List.map viewMediaPlayer model.media_players)
  ]

viewLight : Light -> Html Msg
viewLight msg =
  div [] [ text (toString msg.state.hsbk.hue ++ ": " ++ msg.interface_pid) ]

viewMediaPlayer : MediaPlayer -> Html Msg
viewMediaPlayer msg =
  div [] [ text (toString msg.event_type ++ ": " ++ msg.name) ]
