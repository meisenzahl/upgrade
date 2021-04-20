project('io.elementary.upgrade', 'vala', 'c')

add_global_arguments('-DGETTEXT_PACKAGE="' + meson.project_name() + '"', language:'c')

i18n = import('i18n')

gettext_name = meson.project_name()

prefix = get_option('prefix')
datadir = join_paths(prefix, get_option('datadir'))
pkgdatadir = join_paths(datadir, meson.project_name())
libdir = join_paths(prefix, get_option('libdir'))

granite_dep = dependency('granite')
gtk_dep = dependency('gtk+-3.0')
polkit_dep = dependency('polkit-gobject-1')
posix_dep = meson.get_compiler('vala').find_library('posix')
switchboard_dep = dependency('switchboard-2.0')

polkit_actiondir = polkit_dep.get_pkgconfig_variable('actiondir', define_variable: ['prefix', prefix])
switchboard_plugsdir = switchboard_dep.get_pkgconfig_variable('plugsdir', define_variable: ['libdir', libdir])

daemon_dependencies = [
    polkit_dep,
    posix_dep,
]

plug_dependencies = [
    granite_dep,
    gtk_dep,
    polkit_dep,
    posix_dep,
    switchboard_dep,
]

configuration_data = configuration_data()
configuration_data.set('PKGDATADIR', pkgdatadir)
configuration_data.set('GETTEXT_PACKAGE', gettext_name)

subdir('data')
subdir('src')
subdir('po')
