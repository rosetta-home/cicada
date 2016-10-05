module View.IEQ exposing(..)

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
import Model.IEQ exposing (IEQ)
import Model.Main exposing (Model)
import Msg exposing (Msg)
import Date exposing (Date)
import Time exposing (Time)
import Chart.LineChart as LineChart
import Dict exposing (Dict)
import Util.Layout exposing(card, viewGraph, grey)

view : Model -> IEQ -> Material.Grid.Cell Msg
view model ieq =
  let
    co2 = LineChart.getHistory ieq.interface_pid model.ieq.history .co2
    voc = LineChart.getHistory ieq.interface_pid model.ieq.history .voc
    temp = LineChart.getHistory ieq.interface_pid model.ieq.history .temperature
    humidity = LineChart.getHistory ieq.interface_pid model.ieq.history .humidity
    light = LineChart.getHistory ieq.interface_pid model.ieq.history .light
    co = LineChart.getHistory ieq.interface_pid model.ieq.history .co
    pressure = LineChart.getHistory ieq.interface_pid model.ieq.history .pressure
    sound = LineChart.getHistory ieq.interface_pid model.ieq.history .sound
    rssi = LineChart.getHistory ieq.interface_pid model.ieq.history .rssi
    content =
      [ viewGraph "CO2" (toString ieq.state.co2) (LineChart.view co2)
      , viewGraph "VOC" (toString ieq.state.voc) (LineChart.view voc)
      , viewGraph "Temperature" (toString ieq.state.temperature) (LineChart.view temp)
      , viewGraph "Humidity" (toString ieq.state.humidity) (LineChart.view humidity)
      , viewGraph "Light" (toString ieq.state.light) (LineChart.view light)
      , viewGraph "CO" (toString ieq.state.co) (LineChart.view co)
      , viewGraph "Pressure" (toString ieq.state.pressure) (LineChart.view pressure)
      , viewGraph "Sound" (toString ieq.state.sound) (LineChart.view sound)
      , viewGraph "RSSI" (toString ieq.state.rssi) (LineChart.view rssi)
      ]
  in
    card ieq.name "" content grey [ css "height" "1650px" ]
