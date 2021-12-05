sources = files(
    'Actions/Actions.vala',
    'Actions/ActionType.vala',
    'Actions/Payload.vala',
    'Config/Constants.vala',
    'Middlewares/FeedMiddleware.vala',
    'Middlewares/LoggingMiddleware.vala',
    'Models/Article.vala',
    'Models/Feed.vala',
    'Services/ImageCache.vala',
    'Services/Settings.vala',
    'Store/Store.vala',
    'Utilities/DateTime.vala',
    'Utilities/History.vala',
    'Utilities/URL.vala',
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
    asresources,
    dependencies: dependencies,
    install: true
)
