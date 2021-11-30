import 'package:flutter/material.dart';
import 'package:flutter_navigator2/book.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() {
  setUrlStrategy(PathUrlStrategy());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _routeInfomationParser = AppRouterInformationParser();
  final _routeDelegate = AppRouterDelegate();

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: _routeInfomationParser,
      routerDelegate: _routeDelegate,
    );
  }
}

enum AppRoute {
  public,
  user,
  admin,
}

class AppRoutePath {
  final AppRoute value;
  static final Map<AppRoute, String> routes = {
    AppRoute.public: "/",
    AppRoute.user: "/user",
    AppRoute.admin: "/admin",
  };

  AppRoutePath(this.value);
}

class User {
  final bool canAccessAdmin;

  User(this.canAccessAdmin);
}

class AppRouterInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    var route = AppRoute.public;
    for (var r in AppRoute.values) {
      if ((routeInformation.location ?? '')
          .startsWith(AppRoutePath.routes[r] ?? '/')) {
        route = r;
      }
    }

    return AppRoutePath(route);
  }

  @override
  RouteInformation restoreRouteInformation(AppRoutePath configuration) {
    return RouteInformation(
        location: AppRoutePath.routes[configuration.value] ?? "/");
  }
}

class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;
  User? _user;

  void _handleChangeUser(User? user) {
    _user = user;
    notifyListeners();
  }

  AppRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  @override
  AppRoutePath get currentConfiguration {
    if (_user == null) {
      return AppRoutePath(AppRoute.public);
    }
    if (_user!.canAccessAdmin) {
      return AppRoutePath(AppRoute.admin);
    } else {
      return AppRoutePath(AppRoute.user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
            child: PublicLayout(
          onChangeUser: _handleChangeUser,
        )),
        if (_user != null)
          MaterialPage(
              child: UserLayout(
            onChangeUser: _handleChangeUser,
          )),
        if (_user != null && _user!.canAccessAdmin)
          MaterialPage(
              child: AdminLayout(
            onChangeUser: _handleChangeUser,
          )),
      ],
      onPopPage: (route, result) {
        // TODO
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {
    // TODO
  }
}

class PublicLayout extends StatelessWidget {
  final void Function(User? user) onChangeUser;
  const PublicLayout({Key? key, required this.onChangeUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("公開画面"),
        TextButton(
          child: const Text("ログインする"),
          onPressed: () {
            onChangeUser(User(false));
          },
        ),
      ],
    );
  }
}

class AdminLayout extends StatelessWidget {
  final void Function(User? user) onChangeUser;
  const AdminLayout({Key? key, required this.onChangeUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("管理画面"),
        TextButton(
          child: const Text("ログアウトする"),
          onPressed: () {
            onChangeUser(null);
          },
        ),
      ],
    );
  }
}

class UserLayout extends StatelessWidget {
  final void Function(User? user) onChangeUser;
  const UserLayout({Key? key, required this.onChangeUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("ユーザ画面"),
        TextButton(
          child: const Text("管理者になる"),
          onPressed: () {
            onChangeUser(User(true));
          },
        ),
        TextButton(
          child: const Text("ログアウトする"),
          onPressed: () {
            onChangeUser(null);
          },
        ),
        const Text("上の部分は共通"),
        Expanded(child: BookRouter()),
      ],
    );
  }
}
