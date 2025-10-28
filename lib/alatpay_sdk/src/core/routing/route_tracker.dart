import '../core.dart';

class RouteTracker extends NavigatorObserver {
  static final RouteTracker instance = RouteTracker._();

  RouteTracker._();

  String? _currentRoute;

  String? get currentRoute => _currentRoute;

  @override
  void didPush(Route route, Route? previousRoute) {
    _currentRoute = route.settings.name;
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _currentRoute = previousRoute?.settings.name;
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _currentRoute = previousRoute?.settings.name;
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _currentRoute = newRoute?.settings.name;
  }
}
