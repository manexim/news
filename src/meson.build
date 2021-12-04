sources = files(
    'Actions/Actions.vala',
    'Actions/ActionType.vala',
    'Actions/Payload.vala',
    'Config/Constants.vala',
    'Controllers/ArticleController.vala',
    'Controllers/FeedController.vala',
    'Controllers/WebsiteController.vala',
    'Middlewares/FeedMiddleware.vala',
    'Middlewares/LoggingMiddleware.vala',
    'Models/Article.vala',
    'Models/Feed.vala',
    'Models/Website.vala',
    'Services/ImageCache.vala',
    'Services/Settings.vala',
    'Store/Store.vala',
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
    asresources,
    dependencies: dependencies,
    install: true
)
