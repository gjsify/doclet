# https://github.com/lcallarec/live-chart/blob/master/meson.build
# https://gitlab.gnome.org/GNOME/shotwell/-/blob/master/meson.build
# https://wiki.gnome.org/Projects/Vala/Tools/Meson
# https://github.com/benwaffle/vala-language-server/blob/master/meson.build


project('doclet', 'vala', 'c', version: '0.0.1')

vala_args = ['-fPIC -w --debug -X -w']

sources = files(
  'src/signature/class.vala',
  'src/signature/dependency.vala',
  'src/signature/interface.vala',
  'src/signature/method.vala',
  'src/signature/namespace.vala',
  'src/signature/package.vala',
  'src/signature/parameter.vala',
  'src/signature/property.vala',
  'src/signature/signaturebuilder.vala',
  'src/signature/typeparameter.vala',
  'src/signature/typereference.vala',
  'src/doclet.vala',
  'src/writer.vala',
  'src/generator.vala',
  'src/utils.vala',
)

valac = meson.get_compiler('vala')
libvala_version = run_command(valac, '--api-version').stdout().strip()
libvala = dependency('libvala-@0@'.format(libvala_version), version: '>= 0.51.0')
valadoc = dependency('valadoc-@0@'.format(libvala_version), version: '>= 0.51.0')

dependencies = [
  dependency('glib-2.0'),
  dependency('gio-2.0'),
  dependency('gobject-2.0'),
  libvala,
  valadoc,
  valac.find_library('posix'),
]


lib = shared_library('doclet', sources, dependencies: dependencies)
