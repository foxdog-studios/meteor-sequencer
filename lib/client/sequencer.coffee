class @Sequencer
  constructor: (@_cxt) ->

  createMetronome: (beatsPerMinute, ticksPerBeat) ->
    metronome = new Metronome @_ctx, beatsPerMinute, ticksPerBeat
    new ReactiveMetronome metronome

