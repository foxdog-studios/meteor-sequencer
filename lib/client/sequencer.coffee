class @Sequencer
  constructor: (@_ctx) ->

  createMetronome: (beatsPerMinute, ticksPerBeat) ->
    metronome = new Metronome @_ctx, beatsPerMinute, ticksPerBeat
    new ReactiveMetronome metronome

