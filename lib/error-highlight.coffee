{Point, Range} = require 'atom'
{Disposable} = require 'event-kit'

fileFinder = require './file-finder'

ERROR_REGEX = /\s+error:/
WARNING_REGEX = /\s+warning:/

module.exports.highlightMessages = (data) ->
  for located_file in fileFinder.fileLocationsForLines(data)
    [filename, position, end_position, remaining] = located_file

    highlight_class = if ERROR_REGEX.test(remaining)
      'highlight-error'
    else if WARNING_REGEX.test(remaining)
      'highlight-warning'
    else
      null

    continue unless highlight_class?

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
