module Util.ColorPicker exposing(..)

import Html
import Color exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Html.Attributes exposing (style)
import Msg exposing (Msg)
import Util.MouseEvents as MouseEvents
import String

view : { a | id : Int } -> Html.Html Msg
view device =
  let
    stops = String.join
        ", "
        (List.map(\i ->
          "hsla("++(toString (i*40))++", 100%, 50%, 1.0)" ++ " " ++ (toString ((i+1)*10)) ++ "%"
        ) [0..9])

    alpha_stops = "rgba(255, 255, 255, 0) 0%, rgba(255, 255, 255, 1) 100%"
  in
    Html.canvas
      [ Html.Attributes.style
        [ ("position", "absolute")
        , ("bottom", "0")
        , ("left", "0")
        , ("width", "100%")
        , ("height", "100px")
        , ("background-image", ("linear-gradient(90deg, "++ stops ++")"))
        ]
        , MouseEvents.onClick Msg.GetColor
        , Html.Attributes.class ("color-picker" ++ (toString device.id))
        , Html.Attributes.id ("color-picker" ++ (toString device.id) ++ "svg")
      ]
      [ Html.canvas
        [ Html.Attributes.style
          [ ("position", "absolute")
          , ("bottom", "0")
          , ("left", "0")
          , ("width", "100%")
          , ("height", "100px")
          , ("background-image", ("linear-gradient(180deg, "++ alpha_stops ++")"))
          ]
        ] [ ]
      ]
