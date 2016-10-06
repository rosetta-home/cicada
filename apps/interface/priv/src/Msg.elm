module Msg exposing(..)

import Material
import Model.Lights exposing(LightInterface)
import Time exposing (Time)
import Util.MouseEvents exposing (..)

type Msg
  = DeviceEvent String
  | SelectTab Int
  | Tick Time
  | ToggleLight LightInterface
  | Mdl (Material.Msg Msg)
  | GetColor MouseEvent
  | GotColor String
