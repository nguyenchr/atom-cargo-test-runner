fs   = require 'fs'
path = require 'path'
util = require 'util'

exports.find = (editor) ->
  root = closestPackage editor.getPath()
  if root
    root: root
    test: path.basename editor.getPath()
  else
    root: path.dirname editor.getPath()
    test: path.basename editor.getPath()

closestPackage = (folder) ->
  pkg = path.join folder, 'cargo.toml'
  if fs.existsSync pkg
    folder
  else if folder is '/'
    null
  else
    closestPackage path.dirname(folder)
