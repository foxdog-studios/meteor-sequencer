class @Metronome
  constructor: (audioContext, beatsPerMinute, ticksPerBeat) ->
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

