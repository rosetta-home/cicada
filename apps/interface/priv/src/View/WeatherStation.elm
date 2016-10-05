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
import Model.WeatherStations exposing (WeatherStation, WeatherStationInterface)
import Model.Main exposing (Model)
import Msg exposing (Msg)
import Util.Layout exposing(card, viewGraph, grey)
import Date exposing (Date)
import Time exposing (Time)
import Chart.LineChart as LineChart
import Dict exposing (Dict)

type alias Mdl = Material.Model

view : Model -> WeatherStationInterface -> Material.Grid.Cell Msg
view model weather_station_i =
  let
    weather_station = weather_station_i.device
    indoor_temp = LineChart.getHistory weather_station.interface_pid model.weather_stations.history .indoor_temperature
    outdoor_temp = LineChart.getHistory weather_station.interface_pid model.weather_stations.history .outdoor_temperature
    humidity = LineChart.getHistory weather_station.interface_pid model.weather_stations.history .humidity
    pressure = LineChart.getHistory weather_station.interface_pid model.weather_stations.history .pressure
    rain = LineChart.getHistory weather_station.interface_pid model.weather_stations.history .rain
    uv = LineChart.getHistory weather_station.interface_pid model.weather_stations.history .uv
    content =
      [ viewGraph "Indoor Temperature" (toString weather_station.state.indoor_temperature) (LineChart.view indoor_temp)
      , viewGraph "Outdoor Temperature" (toString weather_station.state.outdoor_temperature) (LineChart.view outdoor_temp)
      , viewGraph "Humidity" (toString weather_station.state.humidity) (LineChart.view humidity)
      , viewGraph "Pressure" (toString weather_station.state.outdoor_temperature) (LineChart.view pressure)
      , viewGraph "Rain" (toString weather_station.state.outdoor_temperature) (LineChart.view rain)
      , viewGraph "UV" (toString weather_station.state.outdoor_temperature) (LineChart.view uv)
      ]
  in
    card weather_station.name "" content grey [ css "height" "1200px" ]
