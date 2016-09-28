module View.WeatherStation exposing(..)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Material
import Material.Button as Button
import Material.Options exposing (css)
import Material.Color as Color
import Material.Card as Card
import Material.Icon as Icon
import Material.Typography as Typography
import Material.Grid exposing (grid, cell, size, Device(..))
import Material.Options as Options exposing (Style)
import Material.Elevation as Elevation
import Model.WeatherStations exposing (WeatherStation)
import Model.Main exposing (Model)
import Msg exposing (Msg)
import Util.Layout exposing(card)
import Date exposing (Date)
import Chart.LineChart as LineChart
import Dict exposing (Dict)

type alias Mdl = Material.Model

now : Int
now = 1475006518000

white : Options.Property c m
white =
  Color.text Color.white

view : Model -> WeatherStation -> Material.Grid.Cell Msg
view model weather_station =
  let
    indoor_temp = case Dict.get weather_station.interface_pid model.weather_stations.history of
      Just list -> (List.indexedMap (\i state -> ( Date.fromTime (toFloat (now+(i*20000))), state.indoor_temperature )) (List.reverse list))
      Nothing -> []
    outdoor_temp = case Dict.get weather_station.interface_pid model.weather_stations.history of
      Just list -> (List.indexedMap (\i state -> ( Date.fromTime (toFloat (now+(i*20000))), state.indoor_temperature )) (List.reverse list))
      Nothing -> []
    content =
      [ viewGraph "Indoor Temperature" (toString weather_station.state.indoor_temperature) (LineChart.view indoor_temp)
      , viewGraph "Outdoor Temperature" (toString weather_station.state.outdoor_temperature) (LineChart.view outdoor_temp)
      ]
  in
    card weather_station.name "" content [ css "height" "450px" ]

viewGraph : String -> String -> Html a -> Html a
viewGraph header subheader graph =
  Options.div []
    [ Options.styled span [ white ] [ text (header ++ " : ") ]
    , Options.styled span [ Typography.caption, white ] [ text subheader ]
    , Options.styled br [ ] [ ]
    , graph
    ]
