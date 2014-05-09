# Web audio polyfill
window.AudioContext = window.AudioContext || window.webkitAudioContext

context = null

@getAudioContext = ->
  context ||= new AudioContext

