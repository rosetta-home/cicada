module Msg exposing(..)

import Material
import Model.Lights exposing(LightInterface)
import Time exposing (Time)

type Msg
  = DeviceEvent String
  | SelectTab Int
  | Tick Time
  | ToggleLight LightInterface
  | Mdl (Material.Msg Msg)
