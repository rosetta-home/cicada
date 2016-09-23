import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Material
import Material.Scheme
import Material.Button as Button
import Material.Options exposing (css)
import Material.Layout as Layout
import Material.Color as Color
import Json.Decode exposing (..)
import Json.Decode.Extra exposing ((|:))
import MediaPlayer exposing (MediaPlayer, decodeMediaPlayer)
import Light exposing (Light, decodeLight)
import Dict exposing (Dict)
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
  , mdl : Material.Model
  , selectedTab : Int
  }

type alias Event =
  { event_type : EventType
  , interface_pid: String
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
    |: ("interface_pid" := string)


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
  (Model [] [] Material.model 0, Cmd.none)

-- UPDATE

decodeDevice : Decoder a -> String -> Maybe a
decodeDevice decoder payload =
  case decodeString decoder payload of
    Ok d -> Just d
    Err _ -> Nothing

deviceList : List { a | interface_pid: String} ->
  Event
  -> String
  -> Decoder { a | interface_pid: String }
  -> List { a | interface_pid: String}
deviceList list evt payload decoder =
  case List.any (\d -> d.interface_pid == evt.interface_pid) list of
    True ->
      List.map (\device ->
        case device.interface_pid == evt.interface_pid of
          True -> case decodeDevice decoder payload of
            Just d -> d
            Nothing -> device
          False -> device
      ) list
    False -> case decodeDevice decoder payload of
      Just d -> d :: list
      Nothing -> list

handleDeviceEvent : String -> Model -> (Model, Cmd Msg)
handleDeviceEvent payload model =
  case decodeString event payload of
    Ok evt ->
      case evt.event_type of
        Light ->
          ({model | lights =
            (deviceList model.lights evt payload decodeLight)}
          , Cmd.none)

        MediaPlayer ->
          ({model | media_players =
            (deviceList model.media_players evt payload decodeMediaPlayer)}
          , Cmd.none)
        _ -> (model, Cmd.none)
    Err _ -> (model, Cmd.none)


type Msg
  = DeviceEvent String
  | SelectTab Int
  | Mdl (Material.Msg Msg)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    DeviceEvent payload -> handleDeviceEvent payload model
    SelectTab tab -> { model | selectedTab = tab } ! []
    Mdl msg' -> Material.update msg' model

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen eventServer DeviceEvent

-- VIEW

type alias Mdl = Material.Model

view : Model -> Html Msg
view model =
  Material.Scheme.topWithScheme Color.Teal Color.LightGreen <|
    Layout.render Mdl
      model.mdl
      [ Layout.fixedHeader
      , Layout.selectedTab model.selectedTab
      , Layout.onSelectTab SelectTab
      ]
      { header = [ h1 [ style [ ( "padding", "2rem" ) ] ] [ text "Rosetta Home 2.0" ] ]
      , drawer = []
      , tabs = ( [ text "Lights", text "Media Players" ], [ Color.background (Color.color Color.Teal Color.S400) ] )
      , main = [ viewBody model ]
      }

viewBody : Model -> Html Msg
viewBody model =
  case model.selectedTab of
    0 -> viewLights model
    1 -> viewMediaPlayers model
    _ -> text "404"

viewLights : Model -> Html Msg
viewLights model =
  div
    [ style [ ( "padding", "2rem" ) ] ]
    [ div [] (List.map viewLight model.lights)
    ]

viewMediaPlayers : Model -> Html Msg
viewMediaPlayers model =
  div
    [ style [ ( "padding", "2rem" ) ] ]
    [ div [] (List.map viewMediaPlayer model.media_players)
    ]

viewLight : Light -> Html Msg
viewLight msg =
  div [] [ text (toString msg.state.tx ++ ": " ++ msg.interface_pid) ]

viewMediaPlayer : MediaPlayer -> Html Msg
viewMediaPlayer msg =
  div [] [ text (msg.interface_pid) ]
