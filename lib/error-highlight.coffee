{Point, Range} = require 'atom'
{Disposable} = require 'event-kit'

fileFinder = require './file-finder'

ERROR_REGEX = new RegExp(fileFinder.PATH_REGEX.source + /\s+error:/.source)
WARNING_REGEX = new RegExp(fileFinder.PATH_REGEX.source + /\s+warning:/.source)

module.exports.highlightMessages = (line) ->
  located_file = fileFinder.fileLocationForLine(line)
  return null unless located_file?
  [filename, position, end_position] = located_file

  highlight_class = if ERROR_REGEX.test(line)
    'highlight-error'
  else if WARNING_REGEX.test(line)
    'highlight-warning'
  else
    null

  return null unless highlight_class?

  active_marker = [null]

  observer_disposable = atom.workspace.observeTextEditors (editor) ->
    return unless editor.getPath() == filename
    active_marker[0]?.destroy()
    marker = if end_position?
      editor.markBufferRange(new Range(position, end_position))
    else
      editor.markBufferPosition(position, invalid: 'surround')
    decoration = editor.decorateMarker(marker, type: 'highlight', class: highlight_class)
    active_marker[0] = marker

  disposer = () ->
    observer_disposable.dispose()
    active_marker[0]?.destroy()
  new Disposable(disposer)
