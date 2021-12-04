namespace Actions {
    void add_feed (string url, string title, string description, string website, string icon) {
        var type = ActionType.ADD_FEED;
        var payload = new Payload.AddFeed () {
            url = url,
            title = title,
            description = description,
            website = website,
            icon = icon
        };

        var action = new Flux.Action (type, payload);
        Flux.Dispatcher.get_instance ().dispatch (action);
    }

    void add_feed_request (string url) {
        var type = ActionType.ADD_FEED_REQUEST;
        var payload = new Payload.AddFeedRequest () {
            url = url
        };

        var action = new Flux.Action (type, payload);
        Flux.Dispatcher.get_instance ().dispatch (action);
    }
}
