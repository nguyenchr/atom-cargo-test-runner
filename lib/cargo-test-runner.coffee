path        = require 'path'
context     = require './context'
Cargo       = require './cargo'
ResultView  = require './result-view'

{CompositeDisposable} = require 'atom'

cargo = null
resultView = null
currentContext = null

module.exports =
  config: # They are only read upon activation (atom bug?), thus the activationCommands for "settings-view:open" in package.json
    cargoBinaryPath:
      type: 'string'
      default: '/usr/local/bin/cargo'
      description: 'Path to the cargo executable'
    showContextInformation:
      type: 'boolean'
      default: false
      description: 'Display extra information for troubleshooting'
    options:
      type: 'string'
      default: ''
      description: 'Append given options always to cargo binary'

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    resultView = new ResultView(state)

    @subscriptions.add atom.commands.add resultView, 'result-view:close', => @close()

    @subscriptions.add atom.commands.add 'atom-workspace', 'core:cancel', => @close()
    @subscriptions.add atom.commands.add 'atom-workspace', 'core:close', => @close()

    @subscriptions.add atom.commands.add 'atom-workspace', 'cargo-test-runner:run': => @run()
    @subscriptions.add atom.commands.add 'atom-workspace', 'cargo-test-runner:run-previous', => @runPrevious()


  deactivate: ->
    if cargo then cargo.stop()
    @subscriptions.dispose()
    resultView.detach()
    resultView = null

  serialize: ->
    resultView.serialize()

  close: ->
    if cargo then cargo.stop()
    resultView.detach()

  run: ->
    editor   = atom.workspace.getActivePaneItem()
    currentContext = context.find editor
    @execute()

  runPrevious: ->
    if currentContext
      @execute()
    else
      @displayError 'No previous test run'


  execute: ->

    resultView.reset()
    if not resultView.hasParent()
      atom.workspace.addBottomPanel item:resultView

    if atom.config.get 'cargo-test-runner.showContextInformation'
      resultView.addLine "Cargo binary:   #{currentContext.cargoBinaryPath}\n"
      resultView.addLine "Root folder:    #{currentContext.root}\n"
      resultView.addLine "Test file:      #{currentContext.test}\n"
      resultView.addLine "PATH:           #{currentContext.path}\n"

    editor = atom.workspace.getActivePaneItem()
    cargo  = new Cargo(currentContext)

    cargo.on 'success', -> resultView.success()
    cargo.on 'failure', -> resultView.failure()
    cargo.on 'updateSummary', (stats) -> resultView.updateSummary(stats)
    cargo.on 'output', (text) -> resultView.addLine(text)
    cargo.on 'error', (err) ->
      resultView.addLine('Failed to run cargo\n' + err.message)
      resultView.failure()

    cargo.run()


  displayError: (message) ->
    resultView.reset()
    resultView.addLine message
    resultView.failure()
    if not resultView.hasParent()
      atom.workspace.addBottomPanel item:resultView
