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
import Material.Options as Options exposing (Style)
import Material.Grid exposing (grid, cell, size, Device(..))
import Material.Elevation as Elevation
import Model.Lights exposing (Light)
import Model.Main exposing (Model)
import Msg exposing (Msg)
import Util.Layout exposing(card)


type alias Mdl = Material.Model

white : Options.Property c m
white =
  Color.text Color.white

view : Model -> Light -> Material.Grid.Cell Msg
view model light =
  let
    content =
      [ Button.render Msg.Mdl [1] model.mdl
          [ Button.icon, Button.ripple ]
          [ Icon.i "phone" ]
      ]
  in
    card light.name (toString light.state.tx) content []
