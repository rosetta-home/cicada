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

convertToHSL : Int -> Int -> Int -> Options.Property c m
convertToHSL hue sat bright =
  let
    l = ( 2 - ((toFloat sat) / 100) ) * ( (toFloat bright) / 2 )
    l_mult = if l < 50 then
      l * 2
    else
      200 - l * 2
    h = hue
    s = (toFloat sat) * ( (toFloat bright) / l_mult )
  in
    css "background" ("hsla(" ++ (toString h) ++ ", " ++ (toString s) ++ "%, " ++ (toString l) ++ "%, 0.85)")


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
    hsbk = light.state.hsbk
    col = if light.state.power == 0 then
      css "background" "hsla(0, 0%, 0%, 1.0)"
    else
      convertToHSL hsbk.hue hsbk.saturation hsbk.brightness
  in
    card light.name (toString light.state.tx) content col []
