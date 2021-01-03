common_sources = [
    'Helpers/Inhibitor.vala',
    'Helpers/StatusParser.vala',
    'Interfaces/UpgradeInterface.vala',
    'Objects/Status.vala',
    'Objects/Step.vala',
    'Upgrade.vala',
    'Utils.vala',
]

daemon_sources = [
    'Services/UpgradeService.vala',
    'Daemon.vala',
    'SessionManager.vala',
]

plug_sources = [
    'Clients/UpgradeClient.vala',
    'Views/AbstractUpgradeView.vala',
    'Views/ErrorView.vala',
    'Views/ProgressView.vala',
    'Views/SuccessView.vala',
    'Views/UpToDateView.vala',
    'Views/WarningView.vala',
    'Views/WelcomeView.vala',
    'Widgets/Terminal.vala',
    'Plug.vala',
]

config_file = configure_file(
    input: 'Config.vala.in',
    output: '@BASENAME@',
    configuration: configuration_data
)

executable(
    meson.project_name() + '.daemon',
    common_sources,
    daemon_sources,
    config_file,
    dependencies: daemon_dependencies,
    install: true
)

shared_module(
    'io.elementary.switchboard.upgrade',
    common_sources,
    plug_sources,
    config_file,
    dependencies: plug_dependencies,
    install: true,
    install_dir : join_paths(switchboard_plugsdir, 'system')
)
