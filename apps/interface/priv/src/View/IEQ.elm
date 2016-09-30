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
import Util.Layout exposing(card, viewGraph)


type alias Mdl = Material.Model

--line_chart_data =
--  [ ( Date.fromTime 1448928000000, 2 )
--  , ( Date.fromTime 1451606400000, 2 )
--  , ( Date.fromTime 1454284800000, 1 )
--  , ( Date.fromTime 1456790400000, 1 )
--  ]

white : Options.Property c m
white =
  Color.text Color.white


view : Model -> IEQ -> Material.Grid.Cell Msg
view model ieq =
  let
    co2 = case Dict.get ieq.interface_pid model.ieq.history of
      Just list -> (List.indexedMap (\i (time, d) -> ( Date.fromTime time, d.state.co2 )) (List.reverse list))
      Nothing -> []
    voc = case Dict.get ieq.interface_pid model.ieq.history of
      Just list -> (List.indexedMap (\i (time, d) -> ( Date.fromTime time, d.state.voc )) (List.reverse list))
      Nothing -> []
    temp = case Dict.get ieq.interface_pid model.ieq.history of
      Just list -> (List.indexedMap (\i (time, d) -> ( Date.fromTime time, d.state.temperature )) (List.reverse list))
      Nothing -> []
    humidity = case Dict.get ieq.interface_pid model.ieq.history of
      Just list -> (List.indexedMap (\i (time, d) -> ( Date.fromTime time, d.state.humidity )) (List.reverse list))
      Nothing -> []
    content =
      [ viewGraph "CO2" (toString ieq.state.co2) (LineChart.view co2)
      , viewGraph "VOC" (toString ieq.state.voc) (LineChart.view voc)
      , viewGraph "Temperature" (toString ieq.state.temperature) (LineChart.view temp)
      , viewGraph "Humidity" (toString ieq.state.humidity) (LineChart.view humidity)
      ]
  in
    card ieq.name "" content [ css "height" "750px" ]
