import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Time exposing (Time, second)
import Material
import Material.Scheme
import Material.Button as Button
import Material.Options exposing (css)
import Material.Layout as Layout
import Material.Icon as Icon
import Material.Color as Color
import Material.Progress as Loading
import Material.Typography as Typography
import Material.Grid exposing (grid, cell, size, Device(..))
import Material.Options as Options exposing (Style)
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
-- SmartMeters
import Model.SmartMeters as SmartMeters
import View.SmartMeter

-- Main
import Model.Main exposing (Model, model)
import Msg exposing (Msg)

-- MODEL
eventServer : String
eventServer =
  "ws://rosetta.local:8081/ws?user_id=3894298374"

historyLength : Int
historyLength = 30

white : Options.Property c m
white =
  Color.text Color.white

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

deviceList : List { a | interface_pid: String }
  -> { a | interface_pid: String }
  -> List { a | interface_pid: String}
deviceList list device =
  case List.any (\d -> d.interface_pid == device.interface_pid) list of
    True ->
      List.map (\d ->
        case d.interface_pid == device.interface_pid of
          True -> device
          False -> d
      ) list
    False ->
      device :: list

updateHistory : { b | state: a, interface_pid: String }
  -> Dict String (List (Time, { b | state : a, interface_pid : String }))
  -> Time
  -> Dict String (List (Time, { b | state : a, interface_pid : String }))
updateHistory device history time =
  case Dict.get device.interface_pid history of
    Just h -> Dict.update device.interface_pid (\l -> Just (List.take historyLength ((time, device) :: h))) history
    Nothing -> Dict.insert device.interface_pid [(time, device)] history

updateModel : { c
    | devices : List { b | interface_pid : String, state : a }
    , history : Dict String (List (Time, { b | interface_pid : String, state : a }))
  }
  -> String
  -> Decoder { b | state : a, interface_pid: String }
  -> Time
  -> { c
    | devices : List { b | state : a, interface_pid : String }
    , history : Dict String (List (Time, { b | interface_pid : String, state : a }))
  }
updateModel model payload decoder time =
  let
    ( devices, history ) = case decodeDevice decoder payload of
      Just d ->
        ( deviceList model.devices d
        , updateHistory d model.history time
        )
      Nothing -> ( model.devices, model.history )
  in
    {model | devices = devices, history = history}

updateLastHistory : { a | history : Dict String (List (Time, b)) } -> Time -> { a | history : Dict String (List (Time, b)) }
updateLastHistory model time =
  let
    history = Dict.map (\k list ->
      case List.head list of
        Just (t, device) -> List.take historyLength ((time, device) :: list)
        Nothing -> list
    ) model.history
  in
    { model | history = history }

handleDeviceEvent : String -> Model -> (Model, Cmd Msg)
handleDeviceEvent payload model =
  case decodeString event payload of
    Ok evt ->
      case evt.event_type of
        Light ->
          let
            lights = updateModel model.lights payload Lights.decodeLight model.time
          in
            ({model | lights = lights}, Cmd.none)
        MediaPlayer ->
          let
            media_players = updateModel model.media_players payload MediaPlayers.decodeMediaPlayer model.time
          in
            ({model | media_players = media_players}, Cmd.none)
        IEQ ->
          let
            ieq = updateModel model.ieq payload IEQ.decodeIEQ model.time
          in
            ({model | ieq = ieq}, Cmd.none)
        WeatherStation ->
          let
            weather_stations = updateModel model.weather_stations payload WeatherStations.decodeWeatherStation model.time
          in
            ({model | weather_stations = weather_stations}, Cmd.none)
        SmartMeter ->
          let
            smart_meters = updateModel model.smart_meters payload SmartMeters.decodeSmartMeter model.time
          in
            ({model | smart_meters = smart_meters}, Cmd.none)
        HVAC ->
          let
            hvac = updateModel model.hvac payload HVAC.decodeHVAC model.time
          in
            ({model | hvac = hvac}, Cmd.none)

        _ -> (model, Cmd.none)
    Err _ -> (model, Cmd.none)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Msg.DeviceEvent payload ->
      if model.time > 0 then
        handleDeviceEvent payload model
      else
        (model, Cmd.none)
    Msg.SelectTab tab -> { model | selectedTab = tab } ! []
    Msg.Mdl msg -> Material.update msg model
    Msg.Tick time ->
      let
        hvac = updateLastHistory model.hvac time
        ieq = updateLastHistory model.ieq time
        lights = updateLastHistory model.lights time
        mp = updateLastHistory model.media_players time
        sm = updateLastHistory model.smart_meters time
        ws = updateLastHistory model.weather_stations time
      in
        ({ model | time = time, hvac = hvac, ieq = ieq, lights = lights, media_players = mp, smart_meters = sm, weather_stations = ws }, Cmd.none)


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ WebSocket.listen eventServer Msg.DeviceEvent
    , Layout.subs Msg.Mdl model.mdl
    , Time.every second Msg.Tick
    ]

-- VIEW

stylesheet : String -> Html a
stylesheet url =
  let
    tag = "link"
    attrs =
      [ attribute "rel" "stylesheet"
      , attribute "property" "stylesheet"
      , attribute "href" url
      ]
    children = []
  in
    node tag attrs children

script : String -> Html a
script url =
  let
    tag = "script"
    attrs =
      [ attribute "defer" ""
      , attribute "src" url
      ]
    children = []
  in
    node tag attrs children

header : Model -> List (Html Msg)
header model =
  [ Layout.row
    [ css "padding" "10px"
    , Color.background (Color.color Color.BlueGrey Color.S700)
    ]
    [ h5 [] [ text "Rosetta Home 2.0" ]
    , Options.styled span [ Typography.caption, Typography.contrast 0.87, white ] [ text (toString model.time) ]
    ]
  ]

view : Model -> Html Msg
view model =
  Layout.render Msg.Mdl model.mdl
    [ Layout.fixedHeader
    , Layout.selectedTab model.selectedTab
    , Layout.onSelectTab Msg.SelectTab
    ]
    { header = header model
    , drawer = []
    , tabs = ( [ text "Lights", text "Media Players", text "IEQ", text "Weather Stations", text "HVAC", text "Smart Meters", text "_____" ], [ Color.background (Color.color Color.BlueGrey Color.S500) ] )
    , main = List.concat [ addMeta, [viewBody model] ]
    }

--<link href='https://fonts.googleapis.com/css?family=Roboto:400,300,500|Roboto+Mono|Roboto+Condensed:400,700&subset=latin,latin-ext' rel='stylesheet' type='text/css'>
--<link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">
--<link rel="stylesheet" href="https://code.getmdl.io/1.2.0/material.min.css" />
addMeta : List (Html a)
addMeta =
  [ node "meta" [ name "viewport", content "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" ] []
  , stylesheet "/static/font-face.css"
  , stylesheet "/static/mdl/material.min.css"
  , script "/static/mdl/material.min.js"
  ]


viewBody : Model -> Html Msg
viewBody model =
  case model.selectedTab of
    0 -> displayTab model model.lights View.Light.view
    1 -> displayTab model model.media_players View.MediaPlayer.view
    2 -> displayTab model model.ieq View.IEQ.view
    3 -> displayTab model model.weather_stations View.WeatherStation.view
    4 -> displayTab model model.hvac View.HVAC.view
    5 -> displayTab model model.smart_meters View.SmartMeter.view
    6 -> displayTab model model.smart_meters View.SmartMeter.view
    _ -> text "404"


displayTab : Model -> { a | devices: List b } -> (Model -> b -> Material.Grid.Cell c) -> Html c
displayTab model typ view =
  if List.length typ.devices == 0 then
    grid [] [ cell [ Material.Grid.size All 4 ] [ Loading.indeterminate ] ]
  else
    grid [] (List.map (view model) typ.devices)

main =
  App.program
    { init = {model | mdl = Layout.setTabsWidth 600 model.mdl} ! [Layout.sub0 Msg.Mdl]
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
