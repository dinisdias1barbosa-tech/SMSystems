import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smsystems/dashboard.dart';
import 'package:smsystems/firebase_options.dart';
import 'package:smsystems/registro.dart';

Future<void> main() async {
WidgetsFlutterBinding.ensureInitialized();

await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
);

runApp(const MyApp());
}

class MyApp extends StatelessWidget {
const MyApp({super.key});

@override
Widget build(BuildContext context) {
return const MaterialApp(
debugShowCheckedModeBanner: false,
home: LoginPage(),
);
}
}

class LoginPage extends StatefulWidget {
const LoginPage({super.key});

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

// Iniciar sessão
Future<void> login() async {
if (loading) return;

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
const SnackBar(
content: Text('Sessão iniciada com sucesso.'),
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

if (e.code == 'user-not-found') {
erro = 'Não existe nenhuma conta com este e-mail.';
} else if (e.code == 'wrong-password') {
erro = 'A palavra-passe está incorreta.';
} else if (e.code == 'invalid-email') {
erro = 'O endereço de e-mail é inválido.';
} else if (e.code == 'invalid-credential') {
erro = 'E-mail ou palavra-passe incorretos.';
} else if (e.code == 'network-request-failed') {
erro = 'Erro de ligação. Verifique a Internet.';
}

debugPrint(e.code);
debugPrint(e.message);

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(erro)),
);
} catch (e) {
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

static const laranja = Color(0xFFF47721);
static const cinzaEscuro = Color(0xFF30343B);
static const cinzaTexto = Color(0xFF667085);

@override
Widget build(BuildContext context) {
final compacto = MediaQuery.sizeOf(context).width < 760;
return Scaffold(
backgroundColor: const Color(0xFFF5F6F7),
body: Stack(
children: [
Positioned.fill(
child: Row(children: [
Container(width: compacto ? 12 : 110, color: const Color(0xFF3D4248)),
const Expanded(child: SizedBox()),
]),
),
SafeArea(
child: Center(
child: SingleChildScrollView(
padding: EdgeInsets.symmetric(horizontal: compacto ? 22 : 40, vertical: 32),
child: ConstrainedBox(
constraints: const BoxConstraints(maxWidth: 1080),
child: compacto
? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
_apresentacao(compacto: true),
const SizedBox(height: 30),
_formulario(),
])
    : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
Expanded(flex: 5, child: _apresentacao(compacto: false)),
const SizedBox(width: 55),
Expanded(flex: 4, child: _formulario()),
]),
),
),
),
),
],
),
);
}

Widget _apresentacao({required bool compacto}) {
return Padding(
padding: EdgeInsets.symmetric(horizontal: compacto ? 4 : 24),
child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
Row(children: [
Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(color: laranja.withOpacity(.12), borderRadius: BorderRadius.circular(14)),
child: const Icon(Icons.handyman, color: laranja, size: 30),
),
const SizedBox(width: 12),
const Text('SERRALHARIA', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: cinzaEscuro)),
]),
const SizedBox(height: 14),
const Text('Acesso à área de trabalho', style: TextStyle(fontSize: 16, color: cinzaTexto)),
SizedBox(height: compacto ? 25 : 58),
_beneficio(Icons.design_services_outlined, 'Projetos à medida', 'Soluções em metal e alumínio.'),
const SizedBox(height: 24),
_beneficio(Icons.verified_outlined, 'Qualidade e precisão', 'Mais durabilidade, mais valor.'),
const SizedBox(height: 24),
_beneficio(Icons.support_agent_outlined, 'Apoio especializado', 'Do orçamento à instalação.'),
]),
);
}

Widget _beneficio(IconData icone, String titulo, String descricao) {
return Row(children: [
Container(
padding: const EdgeInsets.all(10),
decoration: BoxDecoration(
border: Border.all(color: laranja.withOpacity(.35)),
borderRadius: BorderRadius.circular(10),
color: Colors.white,
),
child: Icon(icone, color: laranja, size: 22),
),
const SizedBox(width: 13),
Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700, color: cinzaEscuro)),
const SizedBox(height: 3),
Text(descricao, style: const TextStyle(fontSize: 12, color: cinzaTexto)),
])),
]);
}

InputDecoration _campo(String nome, IconData icone) {
return InputDecoration(
labelText: nome,
labelStyle: const TextStyle(color: cinzaTexto),
prefixIcon: Icon(icone, color: cinzaTexto, size: 20),
filled: true,
fillColor: Colors.white,
contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 14),
enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0xFFDCE0E5))),
border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: laranja, width: 2)),
);
}

Widget _formulario() {
return Container(
padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 34),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(15),
border: Border.all(color: const Color(0xFFE9EAED)),
boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 26, offset: Offset(0, 10))],
),
child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
const Text('Inove a sua', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: cinzaEscuro)),
const Text('Serralharia', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: laranja)),
const SizedBox(height: 13),
const Text('Aceda à sua conta para gerir clientes, orçamentos, projetos e muito mais.', style: TextStyle(fontSize: 13, color: cinzaTexto, height: 1.5)),
const SizedBox(height: 30),
TextField(
controller: emailController,
keyboardType: TextInputType.emailAddress,
decoration: _campo('Endereço de e-mail', Icons.person_outline),
),
const SizedBox(height: 14),
TextField(
controller: passwordController,
obscureText: !mostrarPassword,
onSubmitted: (_) => login(),
decoration: _campo('Palavra-passe', Icons.lock_outline).copyWith(
suffixIcon: IconButton(
tooltip: mostrarPassword ? 'Ocultar palavra-passe' : 'Mostrar palavra-passe',
icon: Icon(mostrarPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: cinzaTexto, size: 20),
onPressed: () => setState(() => mostrarPassword = !mostrarPassword),
),
),
),
const SizedBox(height: 13),
const SizedBox(height: 25),
ElevatedButton(
onPressed: loading ? null : login,
style: ElevatedButton.styleFrom(
backgroundColor: laranja,
foregroundColor: Colors.white,
minimumSize: const Size.fromHeight(49),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
),
child: loading
? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
    : const Text('Entrar', style: TextStyle(fontWeight: FontWeight.w700)),
),
const SizedBox(height: 12),
OutlinedButton(
onPressed: loading ? null : () {
Navigator.push(context, MaterialPageRoute(builder: (_) => Registar()));
},
style: OutlinedButton.styleFrom(
foregroundColor: cinzaEscuro,
minimumSize: const Size.fromHeight(46),
side: const BorderSide(color: Color(0xFFDCE0E5)),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
),
child: const Text('Criar conta'),
),
]),
);
}
}
