import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Registar extends StatefulWidget {
  const Registar({super.key});

  @override
  State<Registar> createState() => _RegistarState();
}

class _RegistarState extends State<Registar> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _idadeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _aGravar = false;
  bool _mostrarPassword = false;
  String? _generoSelecionado;

  static const laranja = Color(0xFFF47721);
  static const preto = Color(0xFF181818);
  static const cinzaEscuro = Color(0xFF30343B);
  static const cinzaTexto = Color(0xFF667085);
  static const fundo = Color(0xFFF5F6F8);

  @override
  void dispose() {
    _nomeController.dispose();
    _idadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registarUtilizador() async {
    if (!_formKey.currentState!.validate()) return;

    if (_generoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o género.'),
        ),
      );
      return;
    }

    setState(() {
      _aGravar = true;
    });

    try {
      final nome = _nomeController.text.trim();
      final idade = _idadeController.text.trim();
      final email = _emailController.text.trim().toLowerCase();
      final password = _passwordController.text;
      final genero = _generoSelecionado!;

      final cred =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'uid': cred.user!.uid,
        'nome': nome,
        'email': email,
        'idade': idade,
        'genero': genero,
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;

      _nomeController.clear();
      _idadeController.clear();
      _emailController.clear();
      _passwordController.clear();

      setState(() {
        _generoSelecionado = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta criada com sucesso.'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String erro = 'Não foi possível criar a conta.';

      if (e.code == 'email-already-in-use') {
        erro = 'Este endereço de e-mail já está registado.';
      } else if (e.code == 'invalid-email') {
        erro = 'O endereço de e-mail é inválido.';
      } else if (e.code == 'weak-password') {
        erro = 'A palavra-passe é demasiado fraca.';
      } else if (e.code == 'network-request-failed') {
        erro = 'Erro de ligação. Verifique a Internet.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro),
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'A conta foi criada, mas ocorreu um erro ao guardar os dados: '
                '${e.message ?? "erro desconhecido"}.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ocorreu um erro inesperado: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _aGravar = false;
        });
      }
    }
  }

  InputDecoration _dec(
      String label,
      IconData icon,
      ) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: cinzaTexto,
        fontSize: 12,
      ),
      prefixIcon: Icon(
        icon,
        color: cinzaTexto,
        size: 19,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
    );
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
                child: _formulario(),
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
          'assets/SMS.jpeg',
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

  Widget _formulario() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
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
                const Expanded(
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
            const SizedBox(height: 22),
            const Text(
              'Crie a sua conta',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: cinzaEscuro,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Comece a gerir a sua serralharia de forma simples e profissional.',
              style: TextStyle(
                fontSize: 10.5,
                color: cinzaTexto,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: _nomeController,
              style: const TextStyle(
                color: cinzaEscuro,
                fontSize: 13,
              ),
              decoration: _dec(
                'Nome completo',
                Icons.person_outline,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Introduza o nome completo.';
                }

                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _idadeController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: cinzaEscuro,
                fontSize: 13,
              ),
              decoration: _dec(
                'Idade',
                Icons.numbers_outlined,
              ),
                validator: (value) {
                  final idade = int.tryParse(
                    value?.trim() ?? '',
                  );

                  if (idade == null) {
                    return 'Introduza uma idade válida.';
                  }

                  return null;
                },

            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _generoSelecionado,
              isExpanded: true,
              dropdownColor: Colors.white,
              style: const TextStyle(
                color: cinzaEscuro,
                fontSize: 13,
              ),
              decoration: _dec(
                'Género',
                Icons.people_outline,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Masculino',
                  child: Text('Masculino'),
                ),
                DropdownMenuItem(
                  value: 'Feminino',
                  child: Text('Feminino'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _generoSelecionado = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Selecione o género.';
                }

                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                color: cinzaEscuro,
                fontSize: 13,
              ),
              decoration: _dec(
                'Endereço de e-mail',
                Icons.email_outlined,
              ),
              validator: (value) {
                final email = value?.trim() ?? '';

                if (email.isEmpty ||
                    !RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(email)) {
                  return 'Introduza um endereço de e-mail válido.';
                }

                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: !_mostrarPassword,
              style: const TextStyle(
                color: cinzaEscuro,
                fontSize: 13,
              ),
              decoration: _dec(
                'Palavra-passe',
                Icons.lock_outline,
              ).copyWith(
                suffixIcon: IconButton(
                  tooltip: _mostrarPassword
                      ? 'Ocultar palavra-passe'
                      : 'Mostrar palavra-passe',
                  icon: Icon(
                    _mostrarPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: cinzaTexto,
                    size: 19,
                  ),
                  onPressed: () {
                    setState(() {
                      _mostrarPassword = !_mostrarPassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Introduza a palavra-passe.';
                }

                if (value.length < 6) {
                  return 'A palavra-passe deve ter pelo menos 6 caracteres.';
                }

                return null;
              },
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 43,
              child: ElevatedButton(
                onPressed:
                _aGravar ? null : _registarUtilizador,
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
                child: _aGravar
                    ? const SizedBox(
                  width: 19,
                  height: 19,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Criar conta',
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
                onPressed: _aGravar
                    ? null
                    : () {
                  Navigator.pop(context);
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
                  'Voltar ao início de sessão',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}