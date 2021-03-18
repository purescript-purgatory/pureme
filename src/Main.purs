module Main where

import Prelude
import Data.List ((!!))
import Data.Maybe (fromMaybe)
import Effect (Effect)
import Effect.Console (log)
import Node.Args (args)
import Node.Encoding as Encoding
import Node.FS.Sync as S
import Node.Globals (__dirname)
import Node.Path as Path
import Text.Handlebars (compile)

path :: Array Path.FilePath -> Path.FilePath
path = Path.concat

writeFile :: String -> String -> Effect Unit
writeFile = S.writeTextFile Encoding.UTF8

readFile :: String -> Effect String
readFile = S.readTextFile Encoding.UTF8

-- Readme Functions
template :: String -> { name :: String, desc :: String } -> String
template handlebars = compile handlebars

getReadmeFile :: String -> String -> String -> String
getReadmeFile name desc contents = template contents { name: name, desc: desc }

writeReadme :: String -> String -> String -> Effect Unit
writeReadme n d c = writeFile (path [ "README.md" ]) $ getReadmeFile n d c

getName :: String
getName = fromMaybe "" (args !! 1)

getDesc :: String
getDesc = fromMaybe "" (args !! 2)

main :: Effect Unit
main = do
  templateContents <- readFile (path [ __dirname, "templates", "README.md.hbs" ])
  writeReadme getName getDesc templateContents
  settings <- readFile (path [ __dirname, ".vscode", "settings.json" ])
  settingsExist <- S.exists $ path [ ".vscode" ]
  if settingsExist then (log ".vscode already exists") else S.mkdir $ path [ ".vscode" ]
  writeFile (path [ ".vscode", "settings.json" ]) settings
  gitignore <- readFile (path [ __dirname, ".gitignore" ])
  writeFile (path [ ".gitignore" ]) gitignore
