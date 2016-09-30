module Msg exposing(..)

import Material
import Time exposing (Time)

type Msg
  = DeviceEvent String
  | SelectTab Int
  | Tick Time
  | Mdl (Material.Msg Msg)
