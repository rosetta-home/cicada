module View.HVAC exposing(..)

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
import Model.HVAC exposing (HVAC)
import Model.Main exposing (Model)
import Msg exposing (Msg)
import Util.Layout exposing(card, grey)

view : Model -> HVAC -> Material.Grid.Cell Msg
view model hvac =
  let
    content =
      [ Button.render Msg.Mdl [1] model.mdl
          [ Button.icon, Button.ripple ]
          [ Icon.i "phone" ]
      ]
  in
    card hvac.name ((toString hvac.state.temperature) ++ " : " ++ (toString hvac.state.state)) content grey []
