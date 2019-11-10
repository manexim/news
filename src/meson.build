sources = files(
    'Config/Constants.vala',
    'Controllers/ArticleController.vala',
    'Controllers/FeedController.vala',
    'Controllers/WebsiteController.vala',
    'Models/Article.vala',
    'Models/Feed.vala',
    'Models/Website.vala',
    'Services/ImageCache.vala',
    'Services/Settings.vala',
    'Services/Sources.vala',
    'Utilities/DateTime.vala',
    'Utilities/History.vala',
    'Utilities/URL.vala',
    'Views/ArticlePreview.vala',
    'Views/ArticleView.vala',
    'Views/FeedView.vala',
    'Views/SourcesView.vala',
    'Views/LoadingView.vala',
    'Widgets/ArticleCarousel.vala',
    'Widgets/ArticleCarouselItem.vala',
    'Widgets/SourceCarousel.vala',
    'Widgets/SourceCarouselItem.vala',
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
