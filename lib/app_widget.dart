import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'my_webview.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ValueNotifier<String> _authStatusNotifier = ValueNotifier<String>('Unknown');

  @override
  void initState() {
    super.initState();
    initPlugin();
  }

  Future<void> initPlugin() async {
    final prefs = await SharedPreferences.getInstance();
    final String? authStatus = prefs.getString('authStatus');
    if (authStatus == null || authStatus != 'authorized') {
      _authStatusNotifier.value = 'Unknown';
    } else {
      _authStatusNotifier.value = authStatus;
    }
  }

  Future<void> updateAuthStatusToAuthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authStatus', 'authorized');
    _authStatusNotifier.value = 'authorized';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiamanteOnline',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ValueListenableBuilder<String>(
        valueListenable: _authStatusNotifier,
        builder: (context, authStatus, child) {
          if (authStatus == 'authorized') {
            return MyWebView();
          } else if (authStatus == 'notAuthorized') {
            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Acesso Restrito',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor:
                    Colors.blue, // Define o fundo do AppBar para azul
              ),
              backgroundColor:
                  Colors.blue, // Define o fundo do Scaffold para azul
              body: Center(
                child: AlertDialog(
                  title: const Text('Permissão do Usuário'),
                  content: const Text(
                    'Você não permitiu coletarmos informações para exibição dos anúncios.\n\n'
                    'Nós nos preocupamos com sua privacidade e segurança de dados. Mantemos este aplicativo gratuito exibindo anúncios. '
                    'Nossos parceiros coletarão dados e usarão um identificador exclusivo em seu dispositivo para exibir anúncios.\n\n'
                    'Para permitir que possamos coletar informações para exibição de anúncios pressione o botão Permitir logo abaixo.\n\n',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        await updateAuthStatusToAuthorized();
                      },
                      child: const Text('Permitir'),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green, // Cor de fundo
                        foregroundColor: Colors.white, // Cor do texto
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Retorna um Scaffold com AlertDialog enquanto o Future está sendo resolvido
            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Acesso Restrito',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor:
                    Colors.blue, // Define o fundo do AppBar para azul
              ),
              backgroundColor:
                  Colors.blue, // Define o fundo do Scaffold para azul
              body: Center(
                child: AlertDialog(
                  title: const Text('Permissão do Usuário'),
                  content: const Text(
                    'Nós nos preocupamos com sua privacidade e segurança de dados. Mantemos este aplicativo gratuito exibindo anúncios. '
                    'Podemos continuar usando seus dados para personalizar anúncios para você?\n\n'
                    'Nossos parceiros coletarão dados e usarão um identificador exclusivo em seu dispositivo para exibir anúncios.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        await updateAuthStatusToAuthorized();
                      },
                      child: const Text('Sim'),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green, // Cor de fundo
                        foregroundColor: Colors.white, // Cor do texto
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _authStatusNotifier.value = 'notAuthorized';
                      },
                      child: const Text('Não'),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red, // Cor de fundo
                        foregroundColor: Colors.white, // Cor do texto
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
