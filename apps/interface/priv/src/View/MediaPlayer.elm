module View.MediaPlayer exposing(..)

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
import Model.MediaPlayers exposing (MediaPlayer)
import Model.Main exposing (Model)
import Msg exposing (Msg)
import String
import Util.Layout exposing(card, grey)

white : Options.Property c m
white =
  Color.text Color.white

view : Model -> MediaPlayer -> Material.Grid.Cell Msg
view model media_player =
  let
    url = "url('" ++ media_player.state.image.url ++ "') center / cover"
    content =
      [ Options.div
          [ css "background" url
          , css "width" "100%"
          , css "height" "80%"
          ]
          [ ]
      ]
    title = if String.isEmpty media_player.state.title then
      media_player.name
    else
      media_player.state.title
  in
    card title "" content grey []
