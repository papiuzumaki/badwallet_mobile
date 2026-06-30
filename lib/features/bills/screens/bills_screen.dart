import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/bills_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/facture.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});
  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth  = context.read<AuthProvider>();
    final bills = context.read<BillsProvider>();
    if (auth.walletCode != null) await bills.loadFactures(auth.walletCode!);
  }

  Future<void> _pay() async {
    final auth  = context.read<AuthProvider>();
    final bills = context.read<BillsProvider>();
    if (auth.phone == null) return;
    final ok = await bills.paySelected(auth.phone!);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kGreen,
          content: Text('Paiement effectué avec succès',
              style: GoogleFonts.poppins(color: Colors.white)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _appBar(),
      body: Consumer<BillsProvider>(builder: (_, prov,_) => _buildBody(prov)),
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
        title: Text('Factures',
            style: GoogleFonts.poppins(
                color: kT1, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: kOrangeFaint,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0x33F59E0B)),
              ),
              child: const Icon(Icons.refresh_rounded, color: kOrange, size: 17),
            ),
            onPressed: _load,
          ),
          const SizedBox(width: 8),
        ],
      );

  Widget _buildBody(BillsProvider prov) {
    if (prov.isLoading) {
      return const Center(child: CircularProgressIndicator(color: kOrange));
    }
    if (prov.factures.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: kGreenFaint,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline_rounded, color: kGreen, size: 32),
            ),
            const SizedBox(height: 16),
            Text('Aucune facture impayée',
                style: GoogleFonts.poppins(
                    color: kT1, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Toutes vos factures sont réglées.',
                style: GoogleFonts.poppins(color: kT2, fontSize: 12.5)),
          ],
        ),
      );
    }

    final selected  = prov.selectedIds;
    final total     = prov.factures
        .where((f) => selected.contains(f.id))
        .fold<double>(0, (s, f) => s + f.amount);
    final n         = NumberFormat('#,##0', 'fr_FR');

    return Column(
      children: [
        // Select all bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: selected.length == prov.factures.length,
                  onChanged: (_) => prov.toggleAll(),
                  activeColor: kOrange,
                  checkColor: Colors.white,
                  side: const BorderSide(color: kT3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(width: 4),
                Text('Tout sélectionner',
                    style: GoogleFonts.poppins(color: kT1, fontSize: 13, fontWeight: FontWeight.w500)),
                const Spacer(),
                Text('${prov.factures.length} facture${prov.factures.length > 1 ? 's' : ''}',
                    style: GoogleFonts.poppins(color: kT2, fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // List
        Expanded(
          child: RefreshIndicator(
            color: kOrange,
            backgroundColor: kCard,
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: prov.factures.length,
              itemBuilder: (_, i) => _billTile(prov.factures[i], prov),
            ),
          ),
        ),

        // Pay bar
        if (selected.isNotEmpty)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: const BoxDecoration(
              color: kSurface,
              border: Border(top: BorderSide(color: kBorder)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${selected.length} sélectionnée${selected.length > 1 ? 's' : ''}',
                            style: GoogleFonts.poppins(color: kT2, fontSize: 11.5)),
                        Text('${n.format(total)} XOF',
                            style: GoogleFonts.poppins(
                                color: kT1, fontSize: 18, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: prov.isPaying ? null : _pay,
                        icon: prov.isPaying
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    color: Colors.black, strokeWidth: 2))
                            : const Icon(Icons.payment_rounded, color: Colors.black, size: 18),
                        label: Text(prov.isPaying ? 'Paiement...' : 'Payer',
                            style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          disabledBackgroundColor: kT3,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _billTile(Facture f, BillsProvider prov) {
    final isSelected = prov.selectedIds.contains(f.id);
    final info       = _providerInfo(f.provider);
    final n          = NumberFormat('#,##0', 'fr_FR');

    return GestureDetector(
      onTap: () => prov.toggleSelection(f.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x1AF59E0B) : kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isSelected ? const Color(0x66F59E0B) : kBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: info.color.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(info.icon, color: info.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f.provider,
                      style: GoogleFonts.poppins(
                          color: kT1, fontSize: 13.5, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text('Mois : ${f.mois}',
                      style: GoogleFonts.poppins(color: kT3, fontSize: 11),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${n.format(f.amount)} XOF',
                    style: GoogleFonts.poppins(
                        color: kOrange, fontSize: 13.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isSelected ? kOrange : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                        color: isSelected ? kOrange : kT3, width: 1.5),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ({IconData icon, Color color}) _providerInfo(String provider) {
    final u = provider.toUpperCase();
    if (u.contains('SENELEC')) return (icon: Icons.bolt_rounded, color: kOrange);
    if (u.contains('WOYAFAL') || u.contains('SDE') || u.contains('WATER')) {
      return (icon: Icons.water_drop_rounded, color: kBlue);
    }
    if (u.contains('ISM') || u.contains('SCHOOL') || u.contains('UNIV')) {
      return (icon: Icons.school_rounded, color: kPrimary);
    }
    if (u.contains('RAPIDO') || u.contains('CANAL') || u.contains('TV')) {
      return (icon: Icons.tv_rounded, color: kGreen);
    }
    return (icon: Icons.receipt_outlined, color: kT2);
  }
}
