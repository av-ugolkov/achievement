typedef EventHandler<T> = void Function(T? args);

class Event<T> {
  late final List<EventHandler<T>> _handlers = [];

  void subscribe(EventHandler<T> handler) {
    _handlers.add(handler);
  }

  void operator +(EventHandler<T> handler) {
    subscribe(handler);
  }

  bool unsubscribe(EventHandler<T> handler) {
    return _handlers.remove(handler);
  }

  bool operator -(EventHandler<T> handler) {
    return unsubscribe(handler);
  }

  void unsubscribeAll() {
    _handlers.clear();
  }

  int get subscriberCount {
    return _handlers.length;
  }

  void callHandlers([T? args]) {
    for (var i = 0; i < _handlers.length; i++) {
      _handlers[i].call(args);
    }
  }

  void callLastHandler([T? args]) {
    if (_handlers.isNotEmpty) {
      _handlers[_handlers.length - 1].call(args);
    }
  }

  @override
  String toString() {
    return runtimeType.toString();
  }
}
