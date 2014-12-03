module Display (display) where
import LinearAlgebra as LA
import Array as A
import Dict as D
import Model (..)
import Util (vectToLoc, locToVect)

display : (Int, Int) -> State -> Element
display (w,h) state =
  let points = D.values state.points
      w' = toFloat w
      h' = toFloat h
      styleAxis = traced (solid black)
      xAxis = styleAxis <| segment (-w'/2, 0) (w'/2, 0)
      yAxis = styleAxis <| segment (0, -h'/2) (0, h'/2)
      dots = map toDot points
      origin = circle 5 |> filled black |> move (0,0)
      (ldaLoc, ldaArrow) = ldaLine points
      projections = if state.projectionsVisible
                       then drawProjections ldaLoc points
                       else []
  in collage w h <| (xAxis::yAxis::origin::dots) ++ ldaArrow ++ projections

drawProjections : Maybe Location -> [Point] -> [Form]
drawProjections mlda points =
  let proj (vx, vy) (vx', vy') = let n = vx*vx' + vy*vy'
                                 in (n*vx, n*vy)
      toDot lda p =
        circle 5 |> outlined (solid (getColor p))
                 |> move (proj lda p.location)
  in case mlda of
       Just lda -> map (toDot lda) points
       Nothing -> []

toDot : Point -> Form
toDot p =
  circle 5 |> filled (getColor p) |> move p.location

getColor : Point -> Color
getColor p = if isOne p then green else blue

ldaLine : [Point] -> (Maybe Location, [Form])
ldaLine points =
  let (ones, twos) = partition isOne points
      toVects = map (.location >> locToVect)
  in case LA.lda (toVects ones) (toVects twos) of
       Just v -> let (x,y) = vectToLoc v
                     line = traced (solid red) <| segment (0,0) (100*x,100*y)
                 in (Just (x,y), [line])
       Nothing -> (Nothing, [])

isOne : Point -> Bool
isOne p = if p.class == One then True else False
