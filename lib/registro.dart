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
  String? _generoSelecionado;

  @override
  void dispose() {
    _nomeController.dispose();
    _idadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Registar utilizador
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
        SnackBar(content: Text(erro)),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'A conta foi criada, mas ocorreu um erro ao guardar os dados: ${e.message ?? "erro desconhecido"}.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ocorreu um erro inesperado: $e'),
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

  InputDecoration _dec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.white70,
      ),
      prefixIcon: Icon(
        icon,
        color: Colors.white70,
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.white38,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.deepPurpleAccent,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF9400D3),
              Color(0xFF191124),
              Color(0xFF000000),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ),
              child: Card(
                color: const Color(0xFF191124),
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.handyman,
                          size: 65,
                          color: Colors.deepPurpleAccent,
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'SERRALHARIA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Criar conta de utilizador',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 25),

                        TextFormField(
                          controller: _nomeController,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: _dec(
                            'Nome completo',
                            Icons.person,
                          ),
                          validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Introduza o nome completo.'
                              : null,
                        ),

                        const SizedBox(height: 15),

                        TextFormField(
                          controller: _idadeController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: _dec(
                            'Idade',
                            Icons.numbers,
                          ),
                          validator: (value) {
                            final idade = int.tryParse(
                              value?.trim() ?? '',
                            );

                            if (idade == null || idade < 18 || idade > 100) {
                              return 'Introduza uma idade válida (18 a 100).';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 15),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white38,
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _generoSelecionado,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF191124),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.people,
                                color: Colors.white70,
                              ),
                            ),
                            hint: const Text(
                              'Selecione o género',
                              style: TextStyle(
                                color: Colors.white70,
                              ),
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
                            validator: (value) => value == null
                                ? 'Selecione o género.'
                                : null,
                          ),
                        ),

                        const SizedBox(height: 15),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: _dec(
                            'Endereço de e-mail',
                            Icons.email,
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

                        const SizedBox(height: 15),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: _dec(
                            'Palavra-passe',
                            Icons.lock,
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

                        const SizedBox(height: 25),

                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                            _aGravar ? null : _registarUtilizador,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _aGravar
                                ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              'Criar conta',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        OutlinedButton(
                          onPressed: _aGravar
                              ? null
                              : () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.white54,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Voltar ao início de sessão'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}