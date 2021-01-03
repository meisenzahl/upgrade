gettext_declaration = configure_file(
    configuration: configuration_data,
    input: 'io.elementary.upgrade.policy.in.in',
    output: '@BASENAME@'
)

i18n.merge_file(
    input: gettext_declaration,
    output: '@BASENAME@',
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    install: true,
    install_dir: polkit_actiondir
)

i18n.merge_file(
    input: meson.project_name() + '.appdata.xml.in',
    output: meson.project_name() + '.appdata.xml',
    po_dir: join_paths(meson.source_root (), 'po', 'extra'),
    install_dir: join_paths(datadir, 'metainfo'),
    install: true
)

install_data(
    meson.project_name() + '.daemon.desktop',
    install_dir: join_paths(get_option('sysconfdir'), 'xdg', 'autostart')
)

install_subdir(
    'files',
    install_dir: pkgdatadir
)

install_data(
    'io.elementary.upgrade.helper',
    install_mode: 'r-xr--r--',
    install_dir: pkgdatadir
)
