import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../services/api_service.dart';
import 'add_draft_page.dart';

class DraftPage extends StatefulWidget {
  const DraftPage({Key? key}) : super(key: key);

  @override
  State<DraftPage> createState() => _DraftPageState();
}

class _DraftPageState extends State<DraftPage> {
  late Future<List<Map<String, dynamic>>> _draftFuture;

  @override
  void initState() {
    super.initState();
    _draftFuture = DBHelper.getDrafts();
  }

  String formatTanggal(dynamic t) {
    try {
      return DateFormat(
        'dd MMM yyyy',
        'id',
      ).format(DateTime.parse(t.toString()));
    } catch (_) {
      return '-';
    }
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
                    itemBuilder: (_, i) =>
                        Image.file(File(fotos[i]), fit: BoxFit.contain),
                  ),
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
              ),
            ),
          );
        },
      ),
    );
  }

  /// ================= POST PESANAN =================
  Future<void> postToPesanan(Map<String, dynamic> draft) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Posting dalam proses...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final success = await ApiService.postPesanan(draft);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (success) {
        // Delete draft after successful upload
        await DBHelper.deleteDraft(draft['id']);

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Posting Laporan Berhasil!'),
              backgroundColor: Colors.green,
            ),
          );

          // Refresh list
          setState(() {
            _draftFuture = DBHelper.getDrafts();
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal Posting Laporan!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// ================= DELETE =================
  Future<void> confirmDelete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Draft'),
        content: const Text('Yakin ingin menghapus draft ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await DBHelper.deleteDraft(id);
      setState(() {
        _draftFuture = DBHelper.getDrafts();
      });
    }
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draft Pesanan Servis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final res = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const AddDraftPage()),
              );
              if (res == true && mounted) {
                setState(() {
                  _draftFuture = DBHelper.getDrafts();
                });
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _draftFuture,
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final drafts = snap.data!;
          if (drafts.isEmpty) {
            return const Center(child: Text('Belum ada draft'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: drafts.length,
            itemBuilder: (_, i) {
              final d = drafts[i];
              final fotos = [d['foto_1'], d['foto_2'], d['foto_3']]
                  .where((e) => e != null && e.toString().isNotEmpty)
                  .cast<String>()
                  .toList();
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
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                  image: d['foto_1'] != null
                                      ? DecorationImage(
                                          image: FileImage(File(d['foto_1'])),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: d['foto_1'] == null
                                    ? const Icon(Icons.image)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      d['kode_transaksi'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${formatTanggal(d['tanggal'])} - Teknisi: ${d['nama_teknisi']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),

                                    const SizedBox(height: 3),
                                    Text(
                                      'Pelanggan: ${d['nama_pelanggan']}',
                                      style: const TextStyle(fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'No. Telp: ${d['nomor_telp']}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Rp ${NumberFormat('#,###', 'id').format(d['biaya'])}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: () => postToPesanan(d),
                                              icon: const Icon(
                                                Icons.cloud_upload,
                                                size: 14,
                                              ),
                                              label: const Text(
                                                'Posting',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            InkWell(
                                              onTap: () =>
                                                  confirmDelete(d['id']),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                child: Icon(
                                                  Icons.delete,
                                                  size: 20,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// LABEL DRAFT
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'DRAFT',
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
          );
        },
      ),
    );
  }
}
