class ImplMetronome
  constructor: (audioContext, beatsPerMinute, ticksPerBeat) ->
    check audioContext, AudioContext
    check beatsPerMinute, Number
    check ticksPerBeat, Number
    @_audioContext = audioContext
    @_beatsPerMinute = beatsPerMinute
    @_ticksPerBeat = ticksPerBeat

  _calcLastTickIndex: ->
    Math.floor @_getCurrentTime() / @_calcSecondsPerTick()

  _calcMinutesPerBeat: ->
    1 / @_beatsPerMinute

  _calcNextTickIndex: ->
    @_calcLastTickIndex() + 1

  _calcSecondsPerBeat: ->
    60 * @_calcMinutesPerBeat()

  _calcSecondsPerTick: ->
    @_calcSecondsPerBeat() / @_ticksPerBeat

  _calcTimeAtNextTick: ->
    @_calcNextTickIndex() * @_calcSecondsPerTick()

  _getCurrentTime: ->
    @_audioContext.currentTime

  getSecondsPerTick: ->
    @_calcSecondsPerTick()

  getTimeAtNextTick: ->
    @_calcTimeAtNextTick()

class ImplReactiveMetronome
  _pollsPerTick: 2

  constructor: (metronome) ->
    check metronome, ImplMetronome
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

createMetronome = (ticksPerBeat) ->
  beatsPerMinute = Meteor.settings.public.track.bpm
  metronome = new ImplMetronome getAudioContext(), beatsPerMinute, ticksPerBeat
  new ImplReactiveMetronome metronome

getBeatMetronome = _.once -> createMetronome 1
getHalfBeatMetronome = _.once -> createMetronome 2

class @Metronome
  @getTimeAtNextBeat: ->
    getBeatMetronome().getTimeAtNextTick()

  @getTimeAtNextHalfBeat: ->
    getHalfBeatMetronome().getTimeAtNextTick()

