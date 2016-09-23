module View.Light exposing(..)

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
import Model.Lights exposing (Light)
import Model.Main exposing (Model)
import Msg exposing (Msg)


type alias Mdl = Material.Model

white : Options.Property c m
white =
  Color.text Color.white

view : Model -> Light -> Material.Grid.Cell Msg
view model light =
  cell [ Material.Grid.size All 4 ]
    [
      Card.view
        [ Color.background (Color.color Color.LightBlue Color.S400)
        ]
        [ Card.title [] [ Card.head [ white ] [ text light.interface_pid ] ]
        , Card.text [ Card.expand ]  [] -- Filler
        , Card.actions
            [ Card.border
            -- Modify flexbox to accomodate small text in action block
            , css "display" "flex"
            , css "justify-content" "space-between"
            , css "align-items" "center"
            , css "padding" "8px 16px 8px 16px"
            , white
            ]
            [ Options.span [ Typography.caption, Typography.contrast 0.87 ] [ text (toString light.state.tx) ]
            , Button.render Msg.Mdl [1] model.mdl
                [ Button.icon, Button.ripple ]
                [ Icon.i "phone" ]
            ]
        ]
      ]
