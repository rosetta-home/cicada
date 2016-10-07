module View.Light exposing(..)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Set exposing (Set)
import String

import Material
import Material.Grid exposing (grid, cell, size, Device(..))
import Material.Color as Color
import Material.Button as Button
import Material.Icon as Icon
import Material.Menu as Menu
import Material.Options as Options exposing (Style, cs, css, div, nop, when)

import Model.Lights exposing (Light, LightInterface)
import Model.Main exposing (Model)

import Util.Layout exposing(card)
import Util.ColorPicker as ColorPicker
import Msg exposing(Msg)

type alias Align =
  ( String, Menu.Property Msg.Msg )

menu : Model -> LightInterface -> Html Msg
menu model light =
  Menu.render Msg.Mdl [ light.id ] model.mdl
    [ Menu.bottomRight
    , Menu.ripple
    , css "position" "absolute"
    , css "right" "16px"
    , css "top" "16px"
    ]
    [ Menu.item
      [ Menu.onSelect (Msg.ToggleLight light) ]
      [ text "Toggle" ]
    , Menu.item
      [ Menu.onSelect (Msg.ToggleLight light) ]
      [ text "Color" ]
    ]

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

view : Model -> LightInterface -> Material.Grid.Cell Msg.Msg
view model light =
  let
    content = [ (menu model light), ColorPicker.view light ]
    hsbk = light.device.state.hsbk
    col = if light.device.state.power == 0 then
      css "background" "hsla(0, 0%, 0%, 1.0)"
    else
      convertToHSL hsbk.hue hsbk.saturation hsbk.brightness
  in
    card light.device.name (toString light.device.state.tx) content col []
