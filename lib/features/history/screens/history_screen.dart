import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/history_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/transaction.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth    = context.read<AuthProvider>();
    final history = context.read<HistoryProvider>();
    if (auth.phone != null) await history.loadHistory(auth.phone!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _appBar(),
      body: Consumer<HistoryProvider>(builder: (_, prov,_) => _buildBody(prov)),
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
        title: Text('Historique',
            style: GoogleFonts.poppins(
                color: kT1, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: kGreenFaint,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0x3310B981)),
              ),
              child: const Icon(Icons.refresh_rounded, color: kGreen, size: 17),
            ),
            onPressed: _load,
          ),
          const SizedBox(width: 8),
        ],
      );

  Widget _buildBody(HistoryProvider prov) {
    if (prov.isLoading) {
      return const Center(child: CircularProgressIndicator(color: kGreen));
    }
    if (prov.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_rounded, color: kT3, size: 48),
            const SizedBox(height: 16),
            Text('Aucune transaction',
                style: GoogleFonts.poppins(
                    color: kT1, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Votre historique est vide.',
                style: GoogleFonts.poppins(color: kT2, fontSize: 12.5)),
          ],
        ),
      );
    }

    // Summary bar
    final credits = prov.transactions.where((t) => t.isCredit).fold<double>(0, (s, t) => s + t.amount);
    final debits  = prov.transactions.where((t) => !t.isCredit).fold<double>(0, (s, t) => s + t.amount);
    final n       = NumberFormat('#,##0', 'fr_FR');

    return Column(
      children: [
        // Summary chips
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Row(
            children: [
              Expanded(child: _summaryChip('+${n.format(credits)} XOF', 'Entrées', kGreen, kGreenFaint, Icons.arrow_downward_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _summaryChip('-${n.format(debits)} XOF', 'Sorties', kRed, kRedFaint, Icons.arrow_upward_rounded)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Row(
            children: [
              Text('${prov.transactions.length} transaction${prov.transactions.length > 1 ? 's' : ''}',
                  style: GoogleFonts.poppins(color: kT2, fontSize: 12.5)),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: kGreen,
            backgroundColor: kCard,
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              itemCount: prov.transactions.length,
              itemBuilder: (_, i) => _txTile(prov.transactions[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryChip(String value, String label, Color color, Color faint, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: faint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withAlpha(40),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(color: color.withAlpha(180), fontSize: 10.5)),
                Text(value,
                    style: GoogleFonts.poppins(
                        color: color, fontSize: 12.5, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _txTile(Transaction tx) {
    final isCredit = tx.isCredit;
    final color    = isCredit ? kGreen : kRed;
    final faint    = isCredit ? kGreenFaint : kRedFaint;
    final icon     = isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final sign     = isCredit ? '+' : '-';
    final n        = NumberFormat('#,##0', 'fr_FR');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: faint, borderRadius: BorderRadius.circular(12)),
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
                const SizedBox(height: 2),
                Text(_fmtDate(tx.createdAt),
                    style: GoogleFonts.poppins(color: kT3, fontSize: 10.5)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$sign${n.format(tx.amount)} XOF',
                  style: GoogleFonts.poppins(
                      color: color, fontSize: 13.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: faint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(isCredit ? 'Crédit' : 'Débit',
                    style: GoogleFonts.poppins(
                        color: color, fontSize: 9.5, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtDate(String raw) {
    try {
      final d = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy · HH:mm', 'fr_FR').format(d);
    } catch (_) {
      return raw.length > 10 ? raw.substring(0, 10) : raw;
    }
  }
}
