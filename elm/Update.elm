module Update (update) where
import LinearAlgebra (..)
import Model (..)
import Util (findPointAtLocation)
import Dict as D

update : Action -> State -> State
update action state =
  case action of
    Mouseup point -> handleMouseup point state
    Mousedown loc -> handleMousedown loc state
    Mousemove loc -> handleMousemove loc state
    ToggleProjections -> toggleProjections state

handleMousedown loc state =
  { state | draggingId <- findPointAtLocation loc state.points }

handleMousemove loc state =
  case state.draggingId of
    Just id -> case D.get id state.points of
                 Nothing -> state
                 Just p -> let p' = { p | location <- loc }
                               points' = D.insert id p' state.points
                           in { state | points <- points' }
    Nothing -> state

handleMouseup point state =
  case state.draggingId of
    Just _ -> { state | draggingId <- Nothing }
    Nothing -> let id = state.freshId
               in { state | points <- D.insert id point state.points
                          , freshId <- id+1
                  }

toggleProjections state =
  { state | projectionsVisible <- not state.projectionsVisible }
