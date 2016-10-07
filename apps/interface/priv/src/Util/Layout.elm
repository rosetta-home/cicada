module Util.Layout exposing(..)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Material
import Material.Button as Button
import Material.Options exposing (css, id)
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

card : String -> String -> String -> List (Html a) -> Style a -> List (Style a) -> Material.Grid.Cell a
card id header subhead content background styles =
  let
    c = List.concat
      [ [ Options.styled p
          [ Typography.title
          , white
          , grey
          , css "margin" "13px 65px 0 13px"
          , css "padding" "3px"
          ] [ text header ]
        , Options.styled p
          [ Typography.caption
          , Typography.contrast 1
          , white
          , grey
          , css "margin" "13px 65px 0 13px"
          , css "padding" "3px"
          ] [ text subhead ]
        ]
        , content
      ]
    styles = List.concat
      [ styles
        , [ Material.Grid.size All 4
          , css "position" "relative"
          , background
          , css "height" "300px"
          , css "border-radius" "2px"
          , Elevation.e3
          , Material.Options.id id
          ]
      ]
  in
    cell styles c

viewGraph : String -> String -> Html a -> Html a
viewGraph header subheader graph =
  Options.div []
    [ Options.styled span
      [ white
      , css "margin-left" "13px" ] [ text (header ++ " : ") ]
    , Options.styled span
      [ Typography.caption
      , lime
      , css "padding" "5px"
      ] [ text subheader ]
    , Options.styled br [ ] [ ]
    , Options.styled div [ css "margin-left" "13px" ] [ graph ]
    ]
