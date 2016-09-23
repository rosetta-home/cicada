module Msg exposing(..)

import Material

type Msg
  = DeviceEvent String
  | SelectTab Int
  | Mdl (Material.Msg Msg)
