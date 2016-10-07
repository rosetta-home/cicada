module Msg exposing(..)

import Material
import Model.Lights exposing(LightInterface)
import Time exposing (Time)
import Util.ImageData exposing (..)
import Dict exposing(Dict)

type Msg
  = DeviceEvent String
  | SelectTab Int
  | Tick Time
  | ToggleLight LightInterface
  | Mdl (Material.Msg Msg)
  | ShowColorPicker String
  | GotColor ColorData
