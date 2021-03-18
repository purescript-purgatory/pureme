module Node.Args where

import Prelude
import Data.List (List, drop, fromFoldable)

foreign import argv :: Array String

args :: List String
args = drop 1 $ fromFoldable argv
