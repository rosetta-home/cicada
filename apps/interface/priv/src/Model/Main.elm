module Model.Main exposing (..)

import Material
import Model.Lights as Lights
import Model.MediaPlayers as MediaPlayers

type alias Model =
  { lights : Lights.Model
  , media_players : MediaPlayers.Model
  , mdl : Material.Model
  , selectedTab : Int
  }

model : Model
model =
  { lights = Lights.model
  , media_players = MediaPlayers.model
  , mdl = Material.model
  , selectedTab = 0
  }

type alias Mdl =
  Material.Model
