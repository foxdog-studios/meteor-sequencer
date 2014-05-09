class @ReactiveMetronome
  _pollsPerTick: 2

  constructor: (metronome) ->
    check metronome, Metronome
    @_metronome = metronome
    @_timeAtNextTickDependency = new Deps.Dependency

  _calcMillisecondsPerPoll: ->
    @_calcMillisecondsPerTick() / @_pollsPerTick

  _calcMillisecondsPerTick: ->
    1000 * @_getSecondsPerTick()

  _depend: ->
    return unless Deps.active
    @_timeAtNextTickDependency.depend()
    @_startPolling() unless @_pollId

  _getSecondsPerTick: ->
    @_metronome.getSecondsPerTick()

  _hasDependents: ->
    @_timeAtNextTickDependency.hasDependents()

  _poll: ->
    if @_hasDependents()
      @_updateTimeAtNextTick()
    else
      @_stopPolling()

  _startPolling: ->
    callback = _.bind @_poll, this
    @_pollId = Meteor.setInterval callback, @_calcMillisecondsPerPoll()

  _stopPolling: ->
    Meteor.clearInterval @_pollId
    delete @_pollId

  _updateTimeAtNextTick: ->
    timeAtNextTick = @_metronome.getTimeAtNextTick()
    if timeAtNextTick != @_timeAtNextTick
      @_timeAtNextTick = timeAtNextTick
      @_timeAtNextTickDependency.changed()

  getTimeAtNextTick: ->
    @_updateTimeAtNextTick()
    @_depend()
    @_timeAtNextTick

