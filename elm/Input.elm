module Input (actions) where
import Model (..)
import Mouse
import Window
import Keyboard

actions : Signal Action
actions = merges [mouseUp, mouseDown, mouseMove, toggleProjections]

toggleProjections =
  lift (always ToggleProjections) <| keepIf identity False Keyboard.space

mouseUp = let down = keepIf not False Mouse.isDown
              class b = if b then One else Two
              makeAction loc shift = Mouseup <| Point loc (class shift)
          in makeAction <~ sampleOn down currentLocation
                         ~ sampleOn down Keyboard.shift

mouseDown = let down = keepIf identity True Mouse.isDown
            in Mousedown <~ sampleOn down currentLocation

mouseMove = Mousemove <~ currentLocation

currentLocation : Signal Location
currentLocation = normalize <~ dimensions' ~ position'

dimensions' : Signal (Float, Float)
dimensions' = lift toFloat2 Window.dimensions

position' : Signal (Float, Float)
position' = lift toFloat2 Mouse.position

toFloat2 : (Int, Int) -> (Float, Float)
toFloat2 (x,y) = (toFloat x, toFloat y)

normalize : Location -> Location -> Location
normalize (w,h) (x,y) = let x' = x - w / 2
                            y' = h / 2 - y
                        in (x', y')
