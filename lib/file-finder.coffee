fs      = require 'fs'
path    = require 'path'
{Point, Range} = require 'atom'

PATH_REGEX = /((?:\w:)?[^:\s\(\)]+):(\d+):(\d+):(\s+(\d+):(\d+))?/g

convertToPosition = (row, col) ->
  row = Math.max(row - 1, 0)
  col = Math.max(~~col - 1, 0)
  new Point(row, col)

module.exports.PATH_REGEX = PATH_REGEX

module.exports.fileLocationForLine = (line) ->
  return null unless line?
  parts = PATH_REGEX.exec(line)
  return null unless parts?
  [filename,row,col, ..., end_row, end_col] = parts.slice(1)
  return null unless filename?

  candidates = (path.resolve(projectPath,filename) for projectPath in atom.project?.getPaths())
  [full_filename, ...] = (file_path for file_path in candidates when fs.existsSync(file_path))

  start_position = convertToPosition(row, col)

  end_position =
    if end_row?
      convertToPosition(end_row, end_col)
    else
      null

  [full_filename, start_position, end_position]
