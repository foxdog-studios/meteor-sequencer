Package.describe({
  summary: 'Music sequencer'
});

Package.on_use(function (api) {
  // Core packages
  api.use('underscore', ['client', 'server']);
  api.use('coffeescript', ['client', 'server']);

  // Our API
  api.add_files('lib/client/metronome.coffee', 'client');
  api.add_files('lib/client/reactive_metronome.coffee', 'client');
  api.add_files('lib/client/sequencer.coffee', 'client')
});

