namespace Actions {
    void add_feed (string url) {
        var type = ActionType.ADD_FEED;
        var payload = new Payload.Feed () {
            url = url
        };

        var action = new Flux.Action (type, payload);
        Flux.Dispatcher.get_instance ().dispatch (action);
    }
}
