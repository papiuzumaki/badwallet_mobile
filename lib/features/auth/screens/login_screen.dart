import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../dashboard/providers/wallet_provider.dart';
import '../../../../core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _ctrl = TextEditingController();
  final _key  = GlobalKey<FormState>();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_key.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_ctrl.text.trim());
    if (ok && mounted) {
      await context.read<WalletProvider>().load(auth.phone!, auth.currency ?? 'XOF');
      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 56),

              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(120),
                      blurRadius: 32,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
              Text('BadWallet',
                  style: GoogleFonts.poppins(
                      color: kT1, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 52),

              // Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kBorder),
                ),
                child: Form(
                  key: _key,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Connexion',
                          style: GoogleFonts.poppins(
                              color: kT1,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Entrez votre numéro pour accéder à votre compte',
                          style: GoogleFonts.poppins(
                              color: kT2, fontSize: 12.5, height: 1.4)),
                      const SizedBox(height: 24),

                      // Label
                      Text('Numéro de téléphone',
                          style: GoogleFonts.poppins(
                              color: kT2,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3)),
                      const SizedBox(height: 8),

                      // Input
                      TextFormField(
                        controller: _ctrl,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 9,
                        style: GoogleFonts.poppins(
                            color: kT1, fontSize: 16, letterSpacing: 1.5),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '77 123 45 67',
                          prefixText: '+221  ',
                          prefixStyle: GoogleFonts.poppins(color: kT2, fontSize: 15),
                          hintStyle: GoogleFonts.poppins(color: kT3, fontSize: 15),
                          filled: true,
                          fillColor: kSurface,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: kBorder)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: kPrimary, width: 1.5)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: kRed)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: kRed)),
                          errorStyle: GoogleFonts.poppins(color: kRed, fontSize: 11),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requis';
                          if (!RegExp(r'^7[0-9]{8}$').hasMatch(v)) {
                            return 'Format invalide — ex: 771234567';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Error
                      Consumer<AuthProvider>(
                        builder: (_, auth, _) {
                          if (auth.error == null) return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: kRedFaint,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0x33EF4444)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: kRed, size: 15),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(auth.error!,
                                      style: GoogleFonts.poppins(color: kRed, fontSize: 12)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Button
                      Consumer<AuthProvider>(
                        builder: (_, auth, _) => SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: auth.isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              disabledBackgroundColor: kT3,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: auth.isLoading
                                ? const SizedBox(width: 20, height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.black, strokeWidth: 2))
                                : Text('Accéder à mon portefeuille',
                                    style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 24, height: 1, color: kBorder),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('BadWallet · Sécurisé',
                        style: GoogleFonts.poppins(color: kT3, fontSize: 11)),
                  ),
                  Container(width: 24, height: 1, color: kBorder),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
