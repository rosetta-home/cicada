module Util.Layout exposing(..)

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
import Msg exposing (Msg)

white : Options.Property c m
white =
  Color.text Color.white

lime : Options.Property c m
lime =
  Color.background (Color.color Color.Lime Color.A700)

grey : Options.Property c m
grey =
  Color.background (Color.color Color.BlueGrey Color.S400)

card : String -> String -> List (Html a) -> Style a -> List (Style a) -> Material.Grid.Cell a
card header subhead content background styles =
  let
    c = List.concat
      [ [ Options.styled p [ Typography.title, white ] [ text header ]
        , Options.styled p [ Typography.caption, Typography.contrast 0.87, white ] [ text subhead ]
        ]
        , content
      ]
    styles = List.concat
      [ styles
        , [ Material.Grid.size All 4
          , background
          , css "height" "300px"
          , css "padding" "13px"
          , css "border-radius" "2px"
          , Elevation.e3
          ]
      ]
  in
    cell styles c

viewGraph : String -> String -> Html a -> Html a
viewGraph header subheader graph =
  Options.div []
    [ Options.styled span [ white ] [ text (header ++ " : ") ]
    , Options.styled span
      [ Typography.caption
      , lime
      , css "padding" "5px"
      ] [ text subheader ]
    , Options.styled br [ ] [ ]
    , graph
    ]
