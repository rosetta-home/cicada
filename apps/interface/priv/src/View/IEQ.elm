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

now : Int
now = 1475006518000

view : Model -> IEQ -> Material.Grid.Cell Msg
view model ieq =
  let
    co2 = case Dict.get ieq.interface_pid model.ieq.history of
      Just list -> (List.indexedMap (\i state -> ( Date.fromTime (toFloat (now+(i*20000))), state.co2 )) (List.reverse list))
      Nothing -> []
    voc = case Dict.get ieq.interface_pid model.ieq.history of
      Just list -> (List.indexedMap (\i state -> ( Date.fromTime (toFloat (now+(i*20000))), state.voc )) (List.reverse list))
      Nothing -> []
    temp = case Dict.get ieq.interface_pid model.ieq.history of
      Just list -> (List.indexedMap (\i state -> ( Date.fromTime (toFloat (now+(i*20000))), state.temperature )) (List.reverse list))
      Nothing -> []
    humidity = case Dict.get ieq.interface_pid model.ieq.history of
      Just list -> (List.indexedMap (\i state -> ( Date.fromTime (toFloat (now+(i*20000))), state.humidity )) (List.reverse list))
      Nothing -> []
  in
    cell [ Material.Grid.size All 4 ]
      [
        Card.view
          [ Color.background (Color.color Color.LightBlue Color.S400)
          , css "max-width" "380px"
          ]
          [ Card.title [ white ] [ text ieq.name ]
          , Card.media
            [ css "background" "none"
            , css "padding-left" "25px"
            ] [ LineChart.view co2
              , LineChart.view voc
              , LineChart.view temp
              , LineChart.view humidity
              ]
          ]
        ]
