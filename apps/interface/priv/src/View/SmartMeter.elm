module View.SmartMeter exposing(..)

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
import Model.SmartMeters exposing (SmartMeter)
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

view : Model -> SmartMeter -> Material.Grid.Cell Msg
view model smart_meter =
  let
    delivered = case Dict.get smart_meter.interface_pid model.smart_meters.history of
      Just list -> (List.indexedMap (\i state -> ( Date.fromTime (toFloat (now+(i*20000))), state.kw_delivered )) (List.reverse list))
      Nothing -> []
    received = case Dict.get smart_meter.interface_pid model.smart_meters.history of
      Just list -> (List.indexedMap (\i state -> ( Date.fromTime (toFloat (now+(i*20000))), state.kw_received )) (List.reverse list))
      Nothing -> []
    demand = case Dict.get smart_meter.interface_pid model.smart_meters.history of
      Just list -> (List.indexedMap (\i state -> ( Date.fromTime (toFloat (now+(i*20000))), state.kw )) (List.reverse list))
      Nothing -> []
    content =
      [ viewGraph "Demand" (toString smart_meter.state.kw) (LineChart.view demand)
      , viewGraph "KW Delivered" (toString smart_meter.state.kw_delivered) (LineChart.view delivered)
      , viewGraph "KW Received" (toString smart_meter.state.kw_received) (LineChart.view received)
      ]
  in
    card smart_meter.name "" content [ css "height" "550px" ]

viewGraph : String -> String -> Html a -> Html a
viewGraph header subheader graph =
  Options.div []
    [ Options.styled span [ white ] [ text (header ++ " : ") ]
    , Options.styled span [ Typography.caption, white ] [ text subheader ]
    , Options.styled br [ ] [ ]
    , graph
    ]