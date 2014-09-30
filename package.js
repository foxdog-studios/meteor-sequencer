Package.describe({
  summary: "[DON'T USE] A reactive music sequencer.",
  version: "0.0.1",
  git: "https://github.com/foxdog-studios/meteor-sequencer"
});

Package.onUse(function (api) {
  api.versionsFrom('METEOR@0.9.0');
  api.use([
    "check",
    "coffeescript",
    "underscore"
  ]);

  api.addFiles("lib/notes.coffee");

  api.addFiles(
    [
      "lib/client/metronome.coffee",
      "lib/client/reactive_metronome.coffee",
      "lib/client/sequencer.coffee",
    ],
    "client"
  );
});

