fs   = require 'fs'
path = require 'path'
util = require 'util'

exports.find = (editor) ->
  root = closestPackage editor.getPath()
  cargoBinary = atom.config.get 'cargo-test-runner.cargoBinaryPath'
  envPath = getCompletePath cargoBinary
  if root
    root: root
    test: path.basename editor.getPath()
    path: envPath
    cargoBinaryPath: cargoBinary
  else
    root: path.dirname editor.getPath()
    test: path.basename editor.getPath()
    path: envPath
    cargoBinaryPath: cargoBinary

getCompletePath = (context, cargoPath) ->
  (process.env.PATH or '').split(path.delimiter).concat(path.dirname(cargoPath)).join(path.delimiter)

closestPackage = (folder) ->
  pkg = path.join folder, 'cargo.toml'
  if fs.existsSync pkg
    folder
  else if folder is '/'
    null
  else
    closestPackage path.dirname(folder)
