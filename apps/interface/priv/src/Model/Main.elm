module Model.Main exposing (..)

import Material
import Model.Lights as Lights
import Model.MediaPlayers as MediaPlayers
import Model.WeatherStations as WeatherStations
import Model.IEQ as IEQ
import Model.HVAC as HVAC

type alias Model =
  { lights : Lights.Model
  , media_players : MediaPlayers.Model
  , ieq: IEQ.Model
  , weather_stations: WeatherStations.Model
  , hvac: HVAC.Model
  , mdl : Material.Model
  , selectedTab : Int
  }

model : Model
model =
  { lights = Lights.model
  , media_players = MediaPlayers.model
  , ieq = IEQ.model
  , weather_stations = WeatherStations.model
  , hvac = HVAC.model
  , mdl = Material.model
  , selectedTab = 0
  }

type alias Mdl =
  Material.Model
