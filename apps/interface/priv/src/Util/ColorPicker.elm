module Util.ColorPicker exposing(..)

import Html
import Html.Attributes exposing(..)
import Color exposing (..)
import String
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Msg exposing (Msg)
import Util.MouseEvents as MouseEvents

view : Html.Html Msg
view =
  let
    stops = Debug.log "CSS Stops"
      (String.join
        ", "
        (List.map(\i ->
          "hsla("++(toString (i*40))++", 100%, 50%, 1.0)" ++ " " ++ (toString ((i+1)*10)) ++ "%"
        ) [0..9]))

    alpha_stops = "rgba(255, 255, 255, 0) 0%, rgba(255, 255, 255, 1) 100%"
  in
    Html.div [ MouseEvents.onClick Msg.GetColor ]
      [ Html.div
        [ Html.Attributes.style
          [ ("position", "absolute")
          , ("bottom", "0")
          , ("left", "0")
          , ("width", "100%")
          , ("height", "100px")
          , ("background", ("linear-gradient(90deg, "++ stops ++")"))
          ]
        ] [ ]
        , Html.div
          [ Html.Attributes.style
            [ ("position", "absolute")
            , ("bottom", "0")
            , ("left", "0")
            , ("width", "100%")
            , ("height", "100px")
            , ("background", ("linear-gradient(90deg, "++ alpha_stops ++")"))
            ]
          ] [ ]
      ]
