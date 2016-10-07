module Msg exposing(..)

import Material
import Model.Lights exposing(LightInterface)
import Time exposing (Time)
import Util.ColorPicker exposing (..)
import Dict exposing(Dict)

type Msg
  = DeviceEvent String
  | SelectTab Int
  | Tick Time
  | Mdl (Material.Msg Msg)
  | ShowColorPicker String
  | HideColorPicker String
  | LightOn String
  | LightOff String
  | GotColor ColorData
