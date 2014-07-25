# ==============================================================================
# = Note                                                                       =
# ==============================================================================

class @Note
  constructor: (duration, pitch) ->
    check duration, Duration
    check pitch, Match.Optional Match.OneOf AbstractPitch, RelativePitch
    @_duration = duration
    @_pitch = pitch

  isPitched: ->
    @_pitch?

  isRest: ->
    not @isPitched()

  getFrequency: ->
    @_pitch.getFrequency()

  getNumBeats: ->
    @_duration.getNumBeats()

  schedule: (bpm, start) ->
    check bpm, Number
    check start, Number
    new ScheduledNote @_duration, @_pitch, bpm, start

class @ScheduledNote extends Note
  constructor: (beats, pitch, bpm, start) ->
    check bpm, Number
    check start, Number
    super beats, pitch
    @_bpm = bpm
    @_start = start

  getStart: ->
    @_start

  getDuration: ->
    @getNumBeats() * 60 / @_bpm

  transpose: (semitones) ->
    newPitch = @_pitch.transpose semitones if @isPitched()
    new ScheduledNote @_duration, newPitch, @_bpm, @_start

# ==============================================================================
# = Pitch                                                                      =
# ==============================================================================

SEMITONES_FROM_C =
  'cb': 11
  'c' :  0
  'c#':  1
  'db':  1
  'd' :  2
  'd#':  3
  'eb':  3
  'e' :  4
  'e#':  5
  'fb':  4
  'f' :  5
  'f#':  6
  'gb':  6
  'g' :  7
  'g#':  8
  'ab':  8
  'a' :  9
  'a#': 10
  'bb': 10
  'b' : 11
  'b#': 12

SEMITONES_TO_NAMES =
  0: 'c'
  1: 'c#'
  2: 'd'
  3: 'd#'
  4: 'e'
  5: 'f'
  6: 'f#'
  7: 'g'
  8: 'g#'
  9: 'a'
  10: 'a#'
  11: 'b'

SEMITONES_PER_OCTAVE = 12

TWELTH_ROOT_OF_TWO = Math.pow 2, 1 / 12

class AbstractPitch
  constructor: (name, octave) ->
    check name, String
    check octave, Number
    @_name = name
    @_octave = octave

  _getSemitonesFromC: ->
    SEMITONES_FROM_C[@getName()]

  getName: ->
    @_name

  getNoteNumber: ->
    @getOctave() * SEMITONES_PER_OCTAVE + @_getSemitonesFromC()

  getOctave: ->
    @_octave

  toString: ->
    "#{ @getName() }#{ @getOctave() } (#{ @getFrequency() })"

  getFrequency: ->
    throw 'Subclass must implement getFrequency() but does not.'

class @AbsolutePitch extends AbstractPitch
  constructor: (name, octave, frequency) ->
    check frequency, Number
    super name, octave
    @_frequency = frequency

  getFrequency: ->
    @_frequency

class @RelativePitch extends AbstractPitch
  constructor: (name, octave, reference) ->
    check reference, AbsolutePitch
    super name, octave
    @_reference = reference

  _getSemitonesFromReference: ->
    @getNoteNumber() - @_reference.getNoteNumber()

  _noteNumberToNameOctave: (noteNumber) ->
    modable =
      if noteNumber < 0
        SEMITONES_PER_OCTAVE - noteNumber
      else
        noteNumber
    name = SEMITONES_TO_NAMES[modable % SEMITONES_PER_OCTAVE]
    octave = Math.floor noteNumber / SEMITONES_PER_OCTAVE
    [name, octave]

  getFrequency: ->
    f0 = @_reference.getFrequency()
    an = Math.pow TWELTH_ROOT_OF_TWO, @_getSemitonesFromReference()
    f0 * an

  transpose: (semitones) ->
    newNoteNumber = @getNoteNumber() + semitones
    [name, octave] = @_noteNumberToNameOctave newNoteNumber
    new RelativePitch name, octave, @_reference


# ==============================================================================
# = Duration                                                                   =
# ==============================================================================

class @Duration
  constructor: (numerator, denominator) ->
    check numerator, Number
    check denominator, Number
    @_numerator = numerator
    @_denominator = denominator

  getNumBeats: ->
    @_numerator / @_denominator


# ==============================================================================
# = Parsing                                                                    =
# ==============================================================================

NOTE_REGEX = /(?:([a-g][b#]?)([0-8])|r)(?:_(\d+)(?:\/(\d+))?)?/i

REFERENCE_NOTE = new AbsolutePitch 'a', 4, 400

class @NoteParser
  @parse: (note) ->
    match = note.match NOTE_REGEX
    throw "Invalid note: #{ note }" unless match

    getInt = (group) ->
      parseInt match[group] || 1
    name = match[1]?.toLowerCase()

    duration = new Duration getInt(3), getInt 4
    pitch = new RelativePitch name, getInt(2), REFERENCE_NOTE if name?
    new Note duration, pitch

class @AbcNoteParser
  constructor: (@_noteLength) ->

  parse: (abcNote) ->
    if abcNote.note != 'rest'
      noteName = abcNote.note[0].toLowerCase()
      if abcNote.note.length == 1
        octave = if abcNote.note == noteName then 5 else 4
      else
        octave = if abcNote.note[2] == ',' then 3 else 6

      if (accidental = abcNote.accidental)?
        if accidental == 'sharp'
          noteName = "#{noteName}#"
        else if accidental == 'flat'
          noteName = "#{noteName}b"
        else if accidental != '='
          throw "Unknown accidental: #{accidental}"
      pitch = new RelativePitch noteName, octave, REFERENCE_NOTE if noteName?
    duration = new Duration abcNote.duration, @_noteLength
    new Note duration, pitch

