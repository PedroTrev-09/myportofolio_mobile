import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/theme.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class PortfolioAppScope extends StatelessWidget {
  const PortfolioAppScope({
    required this.child,
    this.apiClient,
    this.initialToken,
    super.key,
  });
  final Widget child;
  final ApiClient? apiClient;
  final String? initialToken;

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      Provider<ApiClient>(
        create: (_) => apiClient ?? ApiClient(),
        dispose: (_, client) => client.close(),
      ),
      ChangeNotifierProvider(
        create: (context) =>
            AuthState(context.read<ApiClient>(), initialToken: initialToken),
      ),
    ],
    child: child,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({this.apiClient, super.key});
  final ApiClient? apiClient;

  @override
  Widget build(BuildContext context) => PortfolioAppScope(
    apiClient: apiClient,
    child: MaterialApp(
      title: 'MyPortfolio • Haikal Rafka',
      debugShowCheckedModeBanner: false,
      theme: buildPortfolioTheme(Brightness.light),
      darkTheme: buildPortfolioTheme(Brightness.dark),
      home: const MyHomePage(),
    ),
  );
}
