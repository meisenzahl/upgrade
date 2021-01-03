common_sources = [
    'Helpers/Inhibitor.vala',
    'Helpers/StatusParser.vala',
    'Objects/Status.vala',
    'Objects/Step.vala',
    'Upgrade.vala',
    'Utils.vala',
]

app_sources = [
    'Views/AbstractUpgradeView.vala',
    'Views/ErrorView.vala',
    'Views/ProgressView.vala',
    'Views/SuccessView.vala',
    'Views/UpToDateView.vala',
    'Views/WarningView.vala',
    'Views/WelcomeView.vala',
    'Widgets/Terminal.vala',
    'MainWindow.vala',
    'Application.vala',
]

daemon_sources = [
    'Services/DBusServer.vala',
    'Daemon.vala',
    'SessionManager.vala',
]

config_file = configure_file(
    input: 'Config.vala.in',
    output: '@BASENAME@',
    configuration: configuration_data
)

executable(
    meson.project_name(),
    common_sources,
    app_sources,
    config_file,
    dependencies: app_dependencies,
    install: true
)

executable(
    meson.project_name() + '.daemon',
    common_sources,
    daemon_sources,
    config_file,
    dependencies: daemon_dependencies,
    install: true
)
