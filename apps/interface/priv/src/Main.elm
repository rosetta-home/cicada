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
import Material.Grid exposing (grid, cell, size, Device(..))
import Json.Decode exposing (..)
import Json.Decode.Extra exposing ((|:))
import Dict exposing (Dict)
import WebSocket
import Debug

-- MediaPlayers
import Model.MediaPlayers as MediaPlayers
import View.MediaPlayer
-- Lights
import Model.Lights as Lights
import View.Light
-- IEQ
import Model.IEQ as IEQ
import View.IEQ
-- HVAC
import Model.HVAC as HVAC
import View.HVAC
-- WeatherStations
import Model.WeatherStations as WeatherStations
import View.WeatherStation

-- Main
import Model.Main exposing (Model, model)
import Msg exposing (Msg)

-- MODEL
eventServer : String
eventServer =
  "ws://localhost:8081/ws?user_id=3894298374"

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
  | IEQ
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
    "ieq" -> IEQ
    _ -> Unknown

-- UPDATE

decodeDevice : Decoder a -> String -> Maybe a
decodeDevice decoder payload =
  case Debug.log "Parse" (decodeString decoder payload) of
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
          let
            lights = model.lights
            new_lights = {lights | devices = (deviceList model.lights.devices evt payload Lights.decodeLight)}
          in
            ({model | lights = new_lights}, Cmd.none)
        MediaPlayer ->
          let
            media_players = model.media_players
            new_media_players = {media_players | devices = (deviceList model.media_players.devices evt payload MediaPlayers.decodeMediaPlayer)}
          in
            ({model | media_players = new_media_players}, Cmd.none)
        IEQ ->
          let
            ieq = model.ieq
            new_ieq = {ieq | devices = (deviceList model.ieq.devices evt payload IEQ.decodeIEQ)}
          in
            ({model | ieq = new_ieq}, Cmd.none)
        WeatherStation ->
          let
            weather_stations = model.weather_stations
            new_weather_stations = {weather_stations | devices = (deviceList model.weather_stations.devices evt payload WeatherStations.decodeWeatherStation)}
          in
            ({model | weather_stations = new_weather_stations}, Cmd.none)
        HVAC ->
          let
            hvac = model.hvac
            new_hvac = {hvac | devices = (deviceList model.hvac.devices evt payload HVAC.decodeHVAC)}
          in
            ({model | hvac = new_hvac}, Cmd.none)

        _ -> (model, Cmd.none)
    Err _ -> (model, Cmd.none)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Msg.DeviceEvent payload -> handleDeviceEvent payload model
    Msg.SelectTab tab -> { model | selectedTab = tab } ! []
    Msg.Mdl msg -> Material.update msg model

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ WebSocket.listen eventServer Msg.DeviceEvent
    , Layout.subs Msg.Mdl model.mdl
    ]

-- VIEW

view : Model -> Html Msg
view model =
  Material.Scheme.topWithScheme Color.Teal Color.LightGreen <|
    Layout.render Msg.Mdl model.mdl
      [ Layout.fixedHeader
      , Layout.selectedTab model.selectedTab
      , Layout.onSelectTab Msg.SelectTab
      ]
      { header = [ h4 [ style [ ( "padding", "1rem" ) ] ] [ text "Rosetta Home 2.0" ] ]
      , drawer = []
      , tabs = ( [ text "Lights", text "Media Players", text "IEQ", text "Weather Stations", text "HVAC", text "HVAC" ], [ Color.background (Color.color Color.Teal Color.S400) ] )
      , main = [ addMeta, viewBody model ]
      }

addMeta : Html Msg
addMeta =
  node "meta" [ name "viewport", content "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" ] []

viewBody : Model -> Html Msg
viewBody model =
  case model.selectedTab of
    0 -> viewLights model
    1 -> viewMediaPlayers model
    2 -> viewIEQ model
    3 -> viewWeatherStations model
    4 -> viewHVAC model
    5 -> viewHVAC model
    _ -> text "404"

viewLights : Model -> Html Msg
viewLights model =
  grid []
    (List.map (View.Light.view model) model.lights.devices)

viewMediaPlayers : Model -> Html Msg
viewMediaPlayers model =
  grid []
    (List.map (View.MediaPlayer.view model) model.media_players.devices)

viewWeatherStations : Model -> Html Msg
viewWeatherStations model =
  grid []
    (List.map (View.WeatherStation.view model) model.weather_stations.devices)

viewIEQ : Model -> Html Msg
viewIEQ model =
  grid []
    (List.map (View.IEQ.view model) model.ieq.devices)

viewHVAC : Model -> Html Msg
viewHVAC model =
  grid []
    (List.map (View.HVAC.view model) model.hvac.devices)

main =
  App.program
    { init = ( {model | mdl = Layout.setTabsWidth 600 model.mdl}, Layout.sub0 Msg.Mdl )
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
