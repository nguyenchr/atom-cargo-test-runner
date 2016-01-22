fs      = require 'fs'
path    = require 'path'
{Point, Range} = require 'atom'
{$}     = require 'atom-space-pen-views'
fileFinder = require './file-finder'

module.exports.link = (line) ->
  line?.replace(fileFinder.PATH_REGEX,'<a class="flink newFLink">$&</a>')

module.exports.attachClickHandler = ->
  $('.newFLink').on 'click', module.exports.clicked
  .removeClass('.newFLink') # remove "new" marker


module.exports.clicked = ->
  extendedPath = this.innerHTML
  module.exports.open(extendedPath)

module.exports.open = (extendedPath) ->
  located_file = fileFinder.fileLocationForLine(extendedPath)
  return unless located_file?

  [filename, position, end_position] = located_file

  atom.workspace.open(filename)
  .then ->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    editor.scrollToBufferPosition(position, center:true)
    editor.setCursorBufferPosition(position)
