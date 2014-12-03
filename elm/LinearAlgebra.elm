module LinearAlgebra where
import Numeric (..)
import Array (fromList, toList, Array)
import Array as A

lda : [Vector] -> [Vector] -> Maybe Vector
lda c1 c2 =
  case (getMean c1, getMean c2) of
    (Just mean1, Just mean2) ->
      let s1 = scatter c1 mean1
          s2 = scatter c2 mean2
          s = s1 ::+:: s2
      in case inverse s of
           Just inv -> inv ::*: (mean1 :-: mean2)
                         |> normalize
                         |> Just
           Nothing -> Nothing
    _ -> Nothing

scatter : [Vector] -> Vector -> Matrix
scatter vs mean =
  let m = A.fromList <| map (\v -> v :-: mean) vs
  in transpose m ::*:: m

mkMatrix : [[Float]] -> Matrix
mkMatrix = map fromList >> fromList

infixl 6 :+:
(:+:) : Vector -> Vector -> Vector
(:+:) v1 v2 = fromList <| zipWith (+) (toList v1) (toList v2)

infixl 6 :-:
(:-:) : Vector -> Vector -> Vector
(:-:) v1 v2 = fromList <| zipWith (-) (toList v1) (toList v2)

infixl 7 :*:
(:*:) : Vector -> Vector -> Float
(:*:) v1 v2 = sum <| zipWith (*) (toList v1) (toList v2)

infixl 8 .*:
(.*:) : Float -> Vector -> Vector
(.*:) s v = A.map (\x -> x*s) v

infixl 7 ::*:
(::*:) : Matrix -> Vector -> Vector
(::*:) m v = A.map (\v' -> v' :*: v) m

infixl 7 ::*::
(::*::) : Matrix -> Matrix -> Matrix
(::*::) = mmDot

infixl 6 ::+::
(::+::) : Matrix -> Matrix -> Matrix
(::+::) = mmPlus

normalize : Vector -> Vector
normalize v = let n2 = sqNorm v
              in (1 / sqrt n2) .*: v

sqNorm : Vector -> Float
sqNorm v = (v :*: v)

getMean : [Vector] -> Maybe Vector
getMean vs =
  case vs of
    v::vs' -> let v' = foldr (:+:) v vs'
                  len = toFloat (length vs)
              in Just <| (1/len) .*: v'
    [] -> Nothing
