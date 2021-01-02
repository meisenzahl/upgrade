sources = [
    'Helpers/Inhibitor.vala',
    'Helpers/StatusParser.vala',
    'Objects/Status.vala',
    'Objects/Step.vala',
    'Views/AbstractUpgradeView.vala',
    'Views/ErrorView.vala',
    'Views/ProgressView.vala',
    'Views/SuccessView.vala',
    'Views/UpToDateView.vala',
    'Views/WarningView.vala',
    'Views/WelcomeView.vala',
    'Widgets/Terminal.vala',
    'MainWindow.vala',
    'Upgrade.vala',
    'Utils.vala',
    'Application.vala',
]

config_file = configure_file(
    input: 'Config.vala.in',
    output: '@BASENAME@',
    configuration: configuration_data
)

executable(
    meson.project_name(),
    sources,
    config_file,
    dependencies: dependencies,
    install: true
)
