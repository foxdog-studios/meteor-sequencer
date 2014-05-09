class @Sequencer
  constructor: (@audioContext) ->

  createMetronome: (beatsPerMinute, ticksPerBeat) ->
    metronome = new Metronome @audioContext, beatsPerMinute, ticksPerBeat
    new ReactiveMetronome metronome

