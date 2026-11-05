import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smsystems/dashboard.dart';
import 'package:smsystems/firebase_options.dart';
import 'package:smsystems/registro.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseInicializado = false;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    firebaseInicializado = true;
  } catch (e, stackTrace) {
    debugPrint('ERRO AO INICIALIZAR FIREBASE: $e');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(
    MyApp(
      firebaseInicializado: firebaseInicializado,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool firebaseInicializado;

  const MyApp({
    super.key,
    required this.firebaseInicializado,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SM Systems',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
      ),
      home: LoginPage(
        firebaseInicializado: firebaseInicializado,
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  final bool firebaseInicializado;

  const LoginPage({
    super.key,
    required this.firebaseInicializado,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  bool loading = false;
  bool mostrarPassword = false;
  bool manterSessao = false;

  static const laranja = Color(0xFFF47721);
  static const preto = Color(0xFF181818);
  static const cinzaEscuro = Color(0xFF30343B);
  static const cinzaTexto = Color(0xFF667085);
  static const fundo = Color(0xFFF5F6F8);

  @override
  void initState() {
    super.initState();
    manterSessao = false;
  }

  Future<void> login() async {
    if (loading) return;

    if (!widget.firebaseInicializado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O Firebase não foi inicializado. '
                'Verifique a configuração do Firebase.',
          ),
        ),
      );
      return;
    }

    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos.'),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            manterSessao
                ? 'Sessão iniciada com sucesso.'
                : 'Sessão iniciada.',
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const dashboard(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String erro = 'Não foi possível iniciar a sessão.';

      switch (e.code) {
        case 'user-not-found':
          erro = 'Não existe nenhuma conta com este e-mail.';
          break;

        case 'wrong-password':
          erro = 'A palavra-passe está incorreta.';
          break;

        case 'invalid-email':
          erro = 'O endereço de e-mail é inválido.';
          break;

        case 'invalid-credential':
          erro = 'E-mail ou palavra-passe incorretos.';
          break;

        case 'network-request-failed':
          erro = 'Erro de ligação. Verifique a Internet.';
          break;

        case 'too-many-requests':
          erro = 'Demasiadas tentativas. Tente novamente mais tarde.';
          break;

        case 'user-disabled':
          erro = 'Esta conta foi desativada.';
          break;

        case 'operation-not-allowed':
          erro = 'O login por e-mail não está ativado no Firebase.';
          break;
      }

      debugPrint('Firebase Auth error: ${e.code}');
      debugPrint('Firebase Auth message: ${e.message}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('ERRO NO LOGIN: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ocorreu um erro: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            int tipoLayout;

            if (width < 600) {
              tipoLayout = 1;
            } else if (width < 1000) {
              tipoLayout = 2;
            } else {
              tipoLayout = 3;
            }

            return SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width < 600 ? 8 : 20,
                    vertical: 20,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1200,
                    ),
                    child: _layoutResponsivo(
                      tipoLayout,
                      width,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _layoutResponsivo(
      int tipoLayout,
      double width,
      ) {
    double larguraImagem;

    if (tipoLayout == 1) {
      larguraImagem = width * 0.30;
    } else if (tipoLayout == 2) {
      larguraImagem = width * 0.30;
    } else {
      larguraImagem = 380;
    }

    if (larguraImagem < 110) {
      larguraImagem = 110;
    }

    if (larguraImagem > 380) {
      larguraImagem = 380;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 35,
            offset: Offset(0, 15),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: larguraImagem,
              child: _imagemLateral(),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(
                  tipoLayout == 1
                      ? 14
                      : tipoLayout == 2
                      ? 24
                      : 38,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _apresentacao(),
                    SizedBox(
                      height: tipoLayout == 1 ? 20 : 30,
                    ),
                    _formulario(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagemLateral() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/image/SMS.png',
          fit: BoxFit.cover,
          alignment: Alignment.center,
          errorBuilder: (
              BuildContext context,
              Object error,
              StackTrace? stackTrace,
              ) {
            debugPrint(
              'ERRO AO CARREGAR IMAGEM: $error',
            );

            return Container(
              color: preto,
              alignment: Alignment.center,
              child: const Icon(
                Icons.handyman_outlined,
                color: Colors.white,
                size: 70,
              ),
            );
          },
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x22000000),
                Color(0x88000000),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _apresentacao() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE8D8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.handyman_outlined,
                color: laranja,
                size: 25,
              ),
            ),
            const SizedBox(width: 12),
            const Flexible(
              child: Text(
                'SM Systems',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: cinzaEscuro,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Serralharia de confiança\npara os seus projetos.',
          style: TextStyle(
            fontSize: 13,
            height: 1.45,
            color: cinzaTexto,
          ),
        ),
        const SizedBox(height: 30),
        _beneficio(
          Icons.design_services_outlined,
          'Projetos à medida',
          'Soluções em metal e alumínio.',
        ),
        const SizedBox(height: 20),
        _beneficio(
          Icons.verified_outlined,
          'Qualidade e precisão',
          'Mais durabilidade, mais valor.',
        ),
        const SizedBox(height: 20),
        _beneficio(
          Icons.support_agent_outlined,
          'Apoio especializado',
          'Do orçamento à instalação.',
        ),
      ],
    );
  }

  Widget _beneficio(
      IconData icone,
      String titulo,
      String descricao,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0E7),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: const Color(0xFFFFD2B5),
            ),
          ),
          child: Icon(
            icone,
            color: laranja,
            size: 19,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cinzaEscuro,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                descricao,
                style: const TextStyle(
                  fontSize: 10,
                  color: cinzaTexto,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _campo(
      String nome,
      IconData icone,
      ) {
    return InputDecoration(
      labelText: nome,
      labelStyle: const TextStyle(
        fontSize: 12,
        color: cinzaTexto,
      ),
      prefixIcon: Icon(
        icone,
        color: cinzaTexto,
        size: 18,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(
          color: Color(0xFFDDE1E7),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(
          color: laranja,
          width: 1.5,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
      ),
    );
  }

  Widget _formulario() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE8E9ED),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Inove a sua',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: cinzaEscuro,
              height: 1.15,
            ),
          ),
          const Text(
            'Serralharia',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: laranja,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Aceda à sua conta para gerir clientes, '
                'orçamentos, projetos e muito mais.',
            style: TextStyle(
              fontSize: 10.5,
              color: cinzaTexto,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _campo(
              'Endereço de e-mail',
              Icons.person_outline,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: passwordController,
            obscureText: !mostrarPassword,
            onSubmitted: (_) => login(),
            decoration: _campo(
              'Palavra-passe',
              Icons.lock_outline,
            ).copyWith(
              suffixIcon: IconButton(
                tooltip: mostrarPassword
                    ? 'Ocultar palavra-passe'
                    : 'Mostrar palavra-passe',
                icon: Icon(
                  mostrarPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: cinzaTexto,
                  size: 18,
                ),
                onPressed: () {
                  setState(() {
                    mostrarPassword = !mostrarPassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: Checkbox(
                  value: manterSessao,
                  onChanged: (valor) {
                    setState(() {
                      manterSessao = valor ?? false;
                    });
                  },
                  activeColor: laranja,
                  materialTapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 5),
              const Expanded(
                child: Text(
                  'Manter sessão iniciada',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: cinzaTexto,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: TextButton(
                  onPressed: _recuperarPassword,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Esqueceu a palavra-passe?',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      color: laranja,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 43,
            child: ElevatedButton(
              onPressed: loading ? null : login,
              style: ElevatedButton.styleFrom(
                backgroundColor: laranja,
                disabledBackgroundColor:
                const Color(0xFFF5B58D),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: loading
                  ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                'Entrar',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: OutlinedButton(
              onPressed: loading
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Registar(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: cinzaEscuro,
                side: const BorderSide(
                  color: Color(0xFFDCE0E5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: const Text(
                'Criar conta',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _recuperarPassword() async {
    if (!widget.firebaseInicializado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O Firebase não foi inicializado. '
                'Verifique a configuração do Firebase.',
          ),
        ),
      );
      return;
    }

    final email =
    emailController.text.trim().toLowerCase();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Introduza primeiro o seu e-mail.',
          ),
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Foi enviado um e-mail para recuperar a palavra-passe.',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'Password reset error: ${e.code}',
      );

      debugPrint(e.message);

      if (!mounted) return;

      String mensagem =
          'Não foi possível enviar o e-mail.';

      if (e.code == 'user-not-found') {
        mensagem =
        'Não existe nenhuma conta com este e-mail.';
      } else if (e.code == 'invalid-email') {
        mensagem =
        'O endereço de e-mail é inválido.';
      } else if (e.code == 'network-request-failed') {
        mensagem =
        'Erro de ligação. Verifique a Internet.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
        ),
      );
    } catch (e) {
      debugPrint(
        'ERRO AO RECUPERAR PASSWORD: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ocorreu um erro: $e',
          ),
        ),
      );
    }
  }
}