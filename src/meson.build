config_data = configuration_data()
config_data.set('APP_ID', meson.project_name())
config_data.set('APP_VERSION', meson.project_version())

config_file = configure_file(
    input: 'Constants.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

sources = files(
    'Controllers/ArticleController.vala',
    'Controllers/FeedController.vala',
    'Controllers/WebsiteController.vala',
    'Models/Article.vala',
    'Models/Feed.vala',
    'Models/Website.vala',
    'Services/ImageCache.vala',
    'Services/Settings.vala',
    'Utilities/DateTime.vala',
    'Utilities/History.vala',
    'Utilities/URL.vala',
    'Views/ArticlePreview.vala',
    'Views/ArticleView.vala',
    'Views/FeedView.vala',
    'Views/LoadingView.vala',
    'Widgets/ArticleCarousel.vala',
    'Widgets/ArticleCarouselItem.vala',
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
