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
import Model.HVAC exposing (HVAC, HVACInterface)
import Model.Main exposing (Model)
import Msg exposing(Msg)
import Util.Layout exposing(card, grey, white)

view : Model -> HVACInterface -> Material.Grid.Cell Msg
view model hvac =
  let
    content =
      [ Options.styled div
        [ white
        , css "margin" "13px"
        ]
        [ Options.styled div [ ] [ text ("Running: " ++ hvac.device.state.state) ]
        , Options.styled div [ ] [ text ("Current Temperature: " ++ (toString hvac.device.state.temperature)) ]
        , Options.styled div [ ] [ text ("Mode: " ++ hvac.device.state.mode) ]
        , Options.styled div [ ]
          [ case hvac.device.state.mode of
              "cool" -> text ("Cooling to: " ++ (toString hvac.device.state.temporary_target_cool))
              "heat" -> text ("Heating to: " ++ (toString hvac.device.state.temporary_target_heat))
              _ -> text ""
          ]
        , Options.styled div [ ] [ text ("Fan: " ++ hvac.device.state.fan_state) ]
        , Options.styled div [ ] [ text ("Fan Mode: " ++ hvac.device.state.fan_mode) ]
        ]
      ]
  in
    card hvac.device.interface_pid hvac.device.name "" content grey []
