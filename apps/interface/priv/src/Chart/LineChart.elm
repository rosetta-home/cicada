module Chart.LineChart exposing (..)

{-| This module shows how to build a simple line and area chart using some of
the primitives provided in this library.
-}

import Visualization.Scale as Scale exposing (ContinuousScale, ContinuousTimeScale)
import Visualization.Axis as Axis
import Visualization.List as List
import Visualization.Shape as Shape
import Date
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Date exposing (Date)
import String


w : Float
w =
    300


h : Float
h =
    150


padding : Float
padding =
    30


view : List ( Date, Float ) -> Svg msg
view model =
    let
        (start, s_value) = case List.head model of
          Just a -> a
          Nothing -> ( Date.fromTime 0, 0)

        (end, e_value) = case List.head (List.reverse model) of
          Just a -> a
          Nothing -> ( Date.fromTime 0, 0 )

        values = List.map (\(d, val) -> val) model

        min = case List.minimum values of
          Just m -> m
          Nothing -> 0

        max = case List.maximum values of
          Just m -> m
          Nothing -> 1000
        xScale : ContinuousTimeScale
        xScale =
            Scale.time ( start, end ) ( 0, w - 2 * padding )

        yScale : ContinuousScale
        yScale =
            Scale.linear ( min, max ) ( h - 2 * padding, 0 )

        opts : Axis.Options a
        opts =
            Axis.defaultOptions

        xAxis : Svg msg
        xAxis =
            Axis.axis { opts | orientation = Axis.Bottom, tickCount = 10 } xScale

        yAxis : Svg msg
        yAxis =
            Axis.axis { opts | orientation = Axis.Left, tickCount = 5 } yScale

        areaGenerator : ( Date, Float ) -> Maybe ( ( Float, Float ), ( Float, Float ) )
        areaGenerator ( x, y ) =
            Just ( ( Scale.convert xScale x, fst (Scale.rangeExtent yScale) ), ( Scale.convert xScale x, Scale.convert yScale y ) )

        lineGenerator : ( Date, Float ) -> Maybe ( Float, Float )
        lineGenerator ( x, y ) =
            Just ( Scale.convert xScale x, Scale.convert yScale y )

        area : String
        area =
            List.map areaGenerator model
                |> Shape.area Shape.monotoneInXCurve

        line : String
        line =
            List.map lineGenerator model
                |> Shape.line Shape.monotoneInXCurve
    in
        svg [ width (toString w ++ "px"), height (toString h ++ "px") ]
            [ g [ transform ("translate(" ++ toString (padding - 1) ++ ", " ++ toString (h - padding) ++ ")") ]
                [ xAxis ]
            , g [ transform ("translate(" ++ toString (padding - 1) ++ ", " ++ toString padding ++ ")") ]
                [ yAxis ]
            , g [ transform ("translate(" ++ toString padding ++ ", " ++ toString padding ++ ")"), class "series" ]
                [ Svg.path [ d line, stroke "black", strokeWidth "3px", fill "none" ] []
                ]
            ]
