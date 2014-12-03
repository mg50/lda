module Model where
import Dict as D

data Class = One | Two

type Location = (Float, Float)
type Point = { location: Location, class: Class }
type State = { points: D.Dict Int Point
             , draggingId: Maybe Int
             , freshId: Int
             , projectionsVisible: Bool
             }

data Action = Mouseup Point
            | Mousedown Location
            | Mousemove Location
            | ToggleProjections

initialState : State
initialState = State D.empty Nothing 0 False
