fs      = require 'fs'
path    = require 'path'
{Point} = require 'atom'
{$}     = require 'atom-space-pen-views'

PATH_REGEX = /((?:\w:)?[^:\s\(\)]+):(\d+):(\d+)/g

module.exports.link = (line) ->
  return null unless line?
  line.replace(PATH_REGEX,'<a class="flink newFLink">$&</a>')


module.exports.attachClickHandler = ->
  $('.newFLink').on 'click', module.exports.clicked
  .removeClass('.newFLink') # remove "new" marker


module.exports.clicked = ->
  extendedPath = this.innerHTML
  module.exports.open(extendedPath)


module.exports.open = (extendedPath) ->
  parts = PATH_REGEX.exec(extendedPath)
  return unless parts?

  [filename,row,col] = parts.slice(1)
  return unless filename?

  candidates = (path.resolve(projectPath,filename) for projectPath in atom.project?.getPaths())

  [full_filename, ...] = (file_path for file_path in candidates when fs.existsSync(file_path))

  if full_filename?
    atom.workspace.open(full_filename)
    .then ->
      return unless row?

      # align coordinates 0-index-based
      row = Math.max(row - 1, 0)
      col = Math.max(~~col - 1, 0)
      position = new Point(row, col)

      editor = atom.workspace.getActiveTextEditor()
      return unless editor?

      editor.scrollToBufferPosition(position, center:true)
      editor.setCursorBufferPosition(position)
  else
    alert "Could not file #{filename}. Ensure that one of your project folders is the location of your Cargo.toml file."
