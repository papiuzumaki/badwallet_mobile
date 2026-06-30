import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/transfer_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/providers/wallet_provider.dart';
import '../../../../core/theme/app_colors.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});
  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _receiverCtrl = TextEditingController();
  final _amountCtrl   = TextEditingController();
  final _key          = GlobalKey<FormState>();

  @override
  void dispose() {
    _receiverCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_key.currentState!.validate()) return;
    final auth     = context.read<AuthProvider>();
    final transfer = context.read<TransferProvider>();
    final wallet   = context.read<WalletProvider>();
    final result = await transfer.transfer(
      senderPhone: auth.phone!,
      receiverPhone: _receiverCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text.trim()),
    );
    if (result != null && mounted) {
      await wallet.load(auth.phone!, auth.currency ?? 'XOF');
      _receiverCtrl.clear();
      _amountCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _appBar(),
      body: Consumer<TransferProvider>(
        builder: (_, prov,_) {
          if (prov.lastTransfer != null) return _buildSuccess(prov);
          return _buildForm(prov);
        },
      ),
    );
  }

  AppBar _appBar() => AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: kBorder),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: kT1, size: 17),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Transfert d\'argent',
            style: GoogleFonts.poppins(
                color: kT1, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      );

  Widget _buildForm(TransferProvider prov) {
    final auth = context.watch<AuthProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kPrimaryFaint,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x336C5CE7)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: kPrimary, size: 15),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        'Le bénéficiaire doit avoir un compte BadWallet actif.',
                        style: GoogleFonts.poppins(color: kPrimary, fontSize: 11.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _label('Expéditeur'),
            const SizedBox(height: 8),
            _readonlyField(value: auth.phone ?? '—', icon: Icons.person_rounded, iconColor: kPrimary),
            const SizedBox(height: 20),
            _label('Numéro du bénéficiaire'),
            const SizedBox(height: 8),
            _inputField(
              controller: _receiverCtrl,
              hint: '77 000 00 00',
              icon: Icons.person_outline_rounded,
              iconColor: kBlue,
              keyboardType: TextInputType.phone,
              formatter: FilteringTextInputFormatter.digitsOnly,
              maxLength: 9,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requis';
                if (!RegExp(r'^7[0-9]{8}$').hasMatch(v)) return 'Numéro invalide';
                if (v == auth.phone) return 'Vous ne pouvez pas vous envoyer de l\'argent';
                return null;
              },
            ),
            const SizedBox(height: 20),
            _label('Montant (XOF)'),
            const SizedBox(height: 8),
            _inputField(
              controller: _amountCtrl,
              hint: '0',
              icon: Icons.payments_outlined,
              iconColor: kGreen,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              formatter: FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requis';
                final d = double.tryParse(v);
                if (d == null || d <= 0) return 'Montant invalide';
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (prov.error != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: kRedFaint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x33EF4444)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: kRed, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(prov.error!,
                          style: GoogleFonts.poppins(color: kRed, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: prov.isLoading ? null : _send,
                icon: prov.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Icon(Icons.send_rounded, color: Colors.black, size: 18),
                label: Text(prov.isLoading ? 'Envoi...' : 'Envoyer le transfert',
                    style: GoogleFonts.poppins(
                        color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  disabledBackgroundColor: kT3,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess(TransferProvider prov) {
    final tx = prov.lastTransfer!;
    final n  = NumberFormat('#,##0', 'fr_FR');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: kGreenFaint,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x5010B981), width: 2),
              ),
              child: const Icon(Icons.check_circle_outline_rounded, color: kGreen, size: 36),
            ),
            const SizedBox(height: 20),
            Text('Transfert réussi !',
                style: GoogleFonts.poppins(
                    color: kT1, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Votre transfert a été effectué avec succès.',
                style: GoogleFonts.poppins(color: kT2, fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                children: [
                  _detailRow('Montant', '${n.format(tx.amount)} XOF', valueColor: kGreen),
                  const SizedBox(height: 12),
                  _detailRow('Référence', tx.reference),
                  const SizedBox(height: 12),
                  _detailRow('Solde restant', '${n.format(tx.balanceAfter)} XOF'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => prov.reset(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Nouveau transfert',
                    style: GoogleFonts.poppins(
                        color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: kCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: kBorder),
                  ),
                ),
                child: Text('Retour au tableau de bord',
                    style: GoogleFonts.poppins(
                        color: kT2, fontSize: 13, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: GoogleFonts.poppins(
          color: kT2, fontSize: 11.5, fontWeight: FontWeight.w500, letterSpacing: 0.3));

  Widget _readonlyField({
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Text('+221 $value',
              style: GoogleFonts.poppins(color: kT1, fontSize: 14, letterSpacing: 0.5)),
          const Spacer(),
          const Icon(Icons.lock_outline_rounded, color: kT3, size: 14),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
    TextInputType? keyboardType,
    TextInputFormatter? formatter,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: formatter != null ? [formatter] : null,
      maxLength: maxLength,
      style: GoogleFonts.poppins(color: kT1, fontSize: 15),
      decoration: InputDecoration(
        counterText: '',
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: kT3, fontSize: 15),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
        ),
        filled: true,
        fillColor: kSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
      validator: validator,
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(color: kT2, fontSize: 12.5)),
        Text(value,
            style: GoogleFonts.poppins(
                color: valueColor ?? kT1,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}
