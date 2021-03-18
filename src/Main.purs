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

template :: String -> { name :: String, desc :: String } -> String
template handlebars = compile handlebars

getFile :: String -> String -> String -> String
getFile name desc contents = template contents { name: name, desc: desc }

writeReadme :: String -> String -> String -> Effect Unit
writeReadme n d c = S.writeTextFile Encoding.UTF8 (path [ "README.md" ]) $ getFile n d c

writeSettings :: String -> Effect Unit
writeSettings = S.writeTextFile Encoding.UTF8 (path [ ".vscode", "settings.json" ])

writeGitignore :: String -> Effect Unit
writeGitignore = S.writeTextFile Encoding.UTF8 (path [ ".gitignore" ])

getName :: String
getName = fromMaybe "" (args !! 1)

getDesc :: String
getDesc = fromMaybe "" (args !! 2)

main :: Effect Unit
main = do
  templateContents <- S.readTextFile Encoding.UTF8 (path [ __dirname, "templates", "README.md.hbs" ])
  writeReadme getName getDesc templateContents
  settings <- S.readTextFile Encoding.UTF8 (path [ __dirname, ".vscode", "settings.json" ])
  settingsExist <- S.exists $ path [ ".vscode" ]
  if settingsExist then (log ".vscode already exists") else S.mkdir $ path [ ".vscode" ]
  writeSettings settings
  gitignore <- S.readTextFile Encoding.UTF8 (path [ __dirname, ".gitignore" ])
  writeGitignore gitignore
