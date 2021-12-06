config_data = configuration_data()
config_data.set('APP_ID', meson.project_name())
config_data.set('APP_VERSION', meson.project_version())

config_file = configure_file(
    input: 'Constants.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

sources = files(
    'Actions/Actions.vala',
    'Actions/ActionType.vala',
    'Actions/Payload.vala',
    'Middlewares/FeedMiddleware.vala',
    'Middlewares/LoggingMiddleware.vala',
    'Models/Article.vala',
    'Models/Feed.vala',
    'Services/ImageCache.vala',
    'Services/Settings.vala',
    'Store/Store.vala',
    'Utilities/DateTime.vala',
    'Utilities/URL.vala',
    'Views/ArticleView.vala',
    'Widgets/ArticleRow.vala',
    'MainWindow.vala',
    'Application.vala'
)

executable(
    meson.project_name(),
    sources,
    config_file,
    asresources,
    dependencies: dependencies,
    install: true
)
