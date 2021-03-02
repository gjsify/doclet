# https://github.com/lcallarec/live-chart/blob/master/meson.build
# https://gitlab.gnome.org/GNOME/shotwell/-/blob/master/meson.build
# https://wiki.gnome.org/Projects/Vala/Tools/Meson
# https://github.com/benwaffle/vala-language-server/blob/master/meson.build


project('doclet', 'vala', 'c', version: '0.0.1')

vala_args = ['-fPIC -w --debug -X -w']

sources = files(
  'src/doclet.vala',
  'src/writer.vala',
  'src/generator.vala',
  'src/utils.vala',
  'src/signaturebuilder.vala',
  'src/class.vala',
  'src/interface.vala',
  'src/parameter.vala',
  'src/typeparameter.vala',
  'src/typereference.vala',
)

valac = meson.get_compiler('vala')
libvala_version = run_command(valac, '--api-version').stdout().strip()
libvala = dependency('libvala-@0@'.format(libvala_version), version: '>= 0.48.7')

dependencies = [
  dependency('glib-2.0'),
  dependency('gio-2.0'),
  dependency('gobject-2.0'),
  libvala,
  dependency('valadoc-0.48'),
  valac.find_library('posix'),
]


lib = shared_library('doclet', sources, dependencies: dependencies)
