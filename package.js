Package.describe({
  summary: 'A reactive music sequencer'
});

Package.on_use(function (api) {
  api.use('check'       , ['client', 'server']);
  api.use('coffeescript', ['client', 'server']);
  api.use('underscore'  , ['client', 'server']);

  var add_client = function (path) {
    api.add_files('lib/client/' + path, 'client');
  };

  var add_shared = function (path) {
    api.add_files('lib/' + path, ['client', 'server']);
  };

  add_shared('notes.coffee');

  add_client('metronome.coffee');
  add_client('reactive_metronome.coffee');
  add_client('sequencer.coffee');
});

