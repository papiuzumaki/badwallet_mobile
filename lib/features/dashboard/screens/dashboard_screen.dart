import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/transaction.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _hideBalance = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    final auth   = context.read<AuthProvider>();
    final wallet = context.read<WalletProvider>();
    if (auth.phone != null) await wallet.load(auth.phone!, auth.currency ?? 'XOF');
  }

  String _fmt(double amount, String currency) {
    final n = NumberFormat('#,##0', 'fr_FR');
    return '${n.format(amount)} $currency';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Consumer2<AuthProvider, WalletProvider>(
          builder: (_, auth, wallet,_) {
            return RefreshIndicator(
              color: kPrimary,
              backgroundColor: kCard,
              onRefresh: _refresh,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(auth, wallet)),
                  SliverToBoxAdapter(child: _buildBalanceCard(wallet, auth)),
                  SliverToBoxAdapter(child: _buildActions()),
                  SliverToBoxAdapter(child: _buildSectionTitle('Transactions récentes')),
                  if (wallet.isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(child: CircularProgressIndicator(color: kPrimary)),
                      ),
                    )
                  else if (wallet.transactions.isEmpty)
                    SliverToBoxAdapter(child: _buildEmpty())
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _buildTxTile(wallet.transactions[i], wallet.currency),
                        childCount: wallet.transactions.take(5).length,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(AuthProvider auth, WalletProvider wallet) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Image.asset('assets/images/logo.png', width: 40, height: 40, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bonjour,',
                    style: GoogleFonts.poppins(color: kT2, fontSize: 11.5)),
                Text(auth.phone ?? '—',
                    style: GoogleFonts.poppins(
                        color: kT1, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          _IconBtn(
            icon: Icons.power_settings_new_rounded,
            color: kT2,
            onTap: () async {
              await context.read<AuthProvider>().logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(WalletProvider wallet, AuthProvider auth) {
    final balance  = wallet.balance;
    final currency = wallet.currency;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF3A3A3A), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Solde disponible',
                  style: GoogleFonts.poppins(
                      color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w500)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _hideBalance = !_hideBalance),
                child: Icon(
                  _hideBalance ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.white70,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          wallet.isLoading
              ? const SizedBox(
                  height: 36,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(
                  _hideBalance ? '••••••' : _fmt(balance, currency),
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5),
                ),
          const SizedBox(height: 16),
          Row(
            children: [
              _CardChip(
                icon: Icons.phone_iphone_rounded,
                label: auth.phone ?? '—',
              ),
              const SizedBox(width: 10),
              if (auth.walletCode != null)
                _CardChip(
                  icon: Icons.wallet_rounded,
                  label: auth.walletCode!,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Row(
        children: [
          _ActionButton(
            icon: Icons.swap_horiz_rounded,
            label: 'Transfert',
            color: kPrimary,
            faint: kPrimaryFaint,
            onTap: () => Navigator.pushNamed(context, '/transfer'),
          ),
          const SizedBox(width: 12),
          _ActionButton(
            icon: Icons.receipt_long_rounded,
            label: 'Factures',
            color: kOrange,
            faint: kOrangeFaint,
            onTap: () => Navigator.pushNamed(context, '/bills'),
          ),
          const SizedBox(width: 12),
          _ActionButton(
            icon: Icons.history_rounded,
            label: 'Historique',
            color: kGreen,
            faint: kGreenFaint,
            onTap: () => Navigator.pushNamed(context, '/history'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Row(
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  color: kT1, fontSize: 15, fontWeight: FontWeight.w600)),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/history'),
            child: Text('Voir tout',
                style: GoogleFonts.poppins(
                    color: kPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          const Icon(Icons.receipt_long_outlined, color: kT3, size: 40),
          const SizedBox(height: 12),
          Text('Aucune transaction',
              style: GoogleFonts.poppins(color: kT2, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTxTile(Transaction tx, String currency) {
    final isCredit = tx.isCredit;
    final color    = isCredit ? kGreen : kRed;
    final faint    = isCredit ? kGreenFaint : kRedFaint;
    final icon     = isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final sign     = isCredit ? '+' : '-';
    final n        = NumberFormat('#,##0', 'fr_FR');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
                BoxDecoration(color: faint, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.typeLabel,
                    style: GoogleFonts.poppins(
                        color: kT1, fontSize: 13.5, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(tx.reference,
                    style: GoogleFonts.poppins(color: kT3, fontSize: 11),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$sign${n.format(tx.amount)} $currency',
                  style: GoogleFonts.poppins(
                      color: color, fontSize: 13.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(_fmtDate(tx.createdAt),
                  style: GoogleFonts.poppins(color: kT3, fontSize: 10.5)),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtDate(String raw) {
    try {
      final d = DateTime.parse(raw);
      return DateFormat('dd MMM · HH:mm', 'fr_FR').format(d);
    } catch (_) {
      return raw.length > 10 ? raw.substring(0, 10) : raw;
    }
  }
}

// ── Reusable sub-widgets ────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  const _IconBtn(
      {required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

class _CardChip extends StatelessWidget {
  const _CardChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 12),
          const SizedBox(width: 5),
          Text(label,
              style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.faint,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final Color faint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: faint,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(label,
                  style: GoogleFonts.poppins(
                      color: kT1, fontSize: 11.5, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
