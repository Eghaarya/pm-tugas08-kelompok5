import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'login_page.dart';
import '../services/api_service.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({Key? key}) : super(key: key);

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  late Future<List<Map<String, dynamic>>> _pesananFuture;

  @override
  void initState() {
    super.initState();
    _pesananFuture = ApiService.getPesanan();
  }

  String formatTanggal(dynamic t) {
    try {
      if (t == null) return '-';
      return DateFormat(
        'dd MMM yyyy',
        'id',
      ).format(DateTime.parse(t.toString()));
    } catch (_) {
      return '-';
    }
  }

  // Helper untuk mengambil nilai dengan aman
  String _getString(
    Map<String, dynamic> data,
    String key, [
    String defaultValue = '-',
  ]) {
    final value = data[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  dynamic _getNumber(
    Map<String, dynamic> data,
    String key, [
    dynamic defaultValue = 0,
  ]) {
    final value = data[key];
    if (value == null) return defaultValue;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// ================= MODAL FOTO =================
  void showFotoCarousel(BuildContext context, List<String> fotos) {
    final PageController controller = PageController();
    int index = 0;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.black,
            child: SizedBox(
              height: 320,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: controller,
                    itemCount: fotos.length,
                    onPageChanged: (i) => setState(() => index = i),
                    itemBuilder: (_, i) => Image.network(
                      fotos[i],
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      },
                      errorBuilder: (_, __, ___) => const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 60,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Gagal memuat gambar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (fotos.length > 1) ...[
                    Positioned(
                      left: 8,
                      child: IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          size: 40,
                          color: Colors.white,
                        ),
                        onPressed: index > 0
                            ? () => controller.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      right: 8,
                      child: IconButton(
                        icon: const Icon(
                          Icons.chevron_right,
                          size: 40,
                          color: Colors.white,
                        ),
                        onPressed: index < fotos.length - 1
                            ? () => controller.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              )
                            : null,
                      ),
                    ),
                  ],
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// ================= REFRESH =================
  Future<void> _refreshData() async {
    setState(() {
      _pesananFuture = ApiService.getPesanan();
    });
  }

  Future<void> _logout() async {
    await ApiService.clearToken();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginPage(
          onLoginSuccess: () {}, // ⬅️ KOSONGKAN
        ),
      ),
      (route) => false,
    );
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Pesanan Servis'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _pesananFuture,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snap.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _refreshData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final pesanan = snap.data ?? [];

          if (pesanan.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('Belum ada data pesanan'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _refreshData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pesanan.length,
              itemBuilder: (_, i) {
                final p = pesanan[i];

                // Ambil foto dari foto_x_url (URL lengkap dari Laravel)
                final fotos = <String>[];
                for (var key in ['foto_1_url', 'foto_2_url', 'foto_3_url']) {
                  final foto = p[key];
                  if (foto != null &&
                      foto.toString().trim().isNotEmpty &&
                      foto.toString() != 'null') {
                    fotos.add(foto.toString());
                  }
                }

                return GestureDetector(
                  onTap: fotos.isNotEmpty
                      ? () => showFotoCarousel(context, fotos)
                      : null,
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // FOTO THUMBNAIL
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                              ),
                              child: fotos.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        fotos.first,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              );
                                            },
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                              Icons.image,
                                              color: Colors.grey,
                                            ),
                                      ),
                                    )
                                  : const Icon(Icons.image, color: Colors.grey),
                            ),
                            const SizedBox(width: 12),

                            // DETAIL INFO
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getString(p, 'kode_transaksi'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${formatTanggal(p['tanggal'])} - Teknisi: ${_getString(p, 'nama_teknisi')}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),

                                  const SizedBox(height: 6),
                                  Text(
                                    'Pelanggan: ${_getString(p, 'nama_pelanggan')}',
                                    style: const TextStyle(fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'No. Telp: ${_getString(p, 'nomor_telp')}',
                                    style: const TextStyle(fontSize: 13),
                                  ),

                                  const SizedBox(height: 6),
                                  Text(
                                    'Rp ${NumberFormat('#,###', 'id').format(_getNumber(p, 'biaya'))}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// LABEL COMPLETED
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'COMPLETED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
