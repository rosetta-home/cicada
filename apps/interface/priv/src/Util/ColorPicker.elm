module Util.ColorPicker exposing(..)

import Html
import Color exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Html.Attributes exposing (style)
import Msg exposing (Msg)
import Util.MouseEvents as MouseEvents

view : Html.Html Msg
view =
  let
    stops = List.map(\i ->
      stop [ offset ((toString ((i+1)*10)) ++ "%"), stopColor ("hsla("++(toString (i*40))++", 100%, 50%, 1.0)") ] [ ]
    ) [0..9]
    alpha_stops =
      [ stop [ offset "0%", stopColor "white", stopOpacity "0" ] [ ]
      , stop [ offset "100%", stopColor "white", stopOpacity "1" ] [ ]
      ]
  in
    Html.div
      [ Html.Attributes.style
        [ ("position", "absolute")
        , ("bottom", "0")
        , ("left", "0")
        , ("width", "100%")
        , ("height", "100px")
        , ("z-index", "100")
        ]
      ]
      [ svg [ width "100%", height "100px" ]
        [ defs [ ]
          [ linearGradient [ id "colorspectrum", x1 "0%", y1 "0%", x2 "100%", y2 "0%" ] stops
          , linearGradient [ id "alphaspectrum", x1 "0%", y1 "25%", x2 "0%", y2 "95%" ] alpha_stops
          ]
        , rect
          [ fill "url(#colorspectrum)", x "0", y "0", width "100%", height "100px"]
          [  ]
        , rect
          [ fill "url(#alphaspectrum)", x "0", y "0", width "100%", height "100px" ]
          [  ]
        ]
        , Html.div
          [ Html.Attributes.style
            [ ("position", "absolute")
            , ("bottom", "0")
            , ("left", "0")
            , ("width", "100%")
            , ("height", "100%")
            , ("z-index", "100")
            ]
          , MouseEvents.onClick Msg.GetColor
          ] [ ]

      ]
