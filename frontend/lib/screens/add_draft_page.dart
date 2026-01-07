import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../database/db_helper.dart';

class AddDraftPage extends StatefulWidget {
  const AddDraftPage({Key? key}) : super(key: key);

  @override
  State<AddDraftPage> createState() => _AddDraftPageState();
}

class _AddDraftPageState extends State<AddDraftPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaTeknisi = TextEditingController();
  final TextEditingController _namaPelanggan = TextEditingController();
  final TextEditingController _nomorTelp = TextEditingController();
  final TextEditingController _biaya = TextEditingController();

  DateTime _tanggal = DateTime.now();

  File? foto1;
  File? foto2;
  File? foto3;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFoto(int index) async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (picked == null) return;

    setState(() {
      if (index == 1) foto1 = File(picked.path);
      if (index == 2) foto2 = File(picked.path);
      if (index == 3) foto3 = File(picked.path);
    });
  }

  Widget _fotoBox(File? foto, int index) {
    return GestureDetector(
      onTap: () => _pickFoto(index),
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          image: foto != null
              ? DecorationImage(image: FileImage(foto), fit: BoxFit.cover)
              : null,
        ),
        child: foto == null
            ? const Icon(Icons.camera_alt, color: Colors.grey)
            : null,
      ),
    );
  }

  Future<void> _simpanDraft() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final kodeTransaksi = 'TRX-${now.millisecondsSinceEpoch}';

    await DBHelper.insertDraft({
      'kode_transaksi': kodeTransaksi,
      'tanggal': DateFormat('yyyy-MM-dd').format(_tanggal),
      'biaya': double.parse(_biaya.text),
      'nama_teknisi': _namaTeknisi.text,
      'nama_pelanggan': _namaPelanggan.text,
      'nomor_telp': _nomorTelp.text,
      'foto_1': foto1?.path,
      'foto_2': foto2?.path,
      'foto_3': foto3?.path,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _namaTeknisi.dispose();
    _namaPelanggan.dispose();
    _nomorTelp.dispose();
    _biaya.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Draft Pesanan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField('Nama Teknisi', _namaTeknisi),
              _buildField('Nama Pelanggan', _namaPelanggan),
              _buildField(
                'Nomor Telepon',
                _nomorTelp,
                keyboardType: TextInputType.phone,
              ),
              _buildField('Biaya', _biaya, keyboardType: TextInputType.number),

              const SizedBox(height: 16),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tanggal Servis'),
                subtitle: Text(
                  DateFormat('dd MMM yyyy', 'id').format(_tanggal),
                ),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _tanggal,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _tanggal = picked);
                  }
                },
              ),

              const SizedBox(height: 16),
              const Text(
                'Foto Servis (Opsional)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _fotoBox(foto1, 1),
                  _fotoBox(foto2, 2),
                  _fotoBox(foto3, 3),
                ],
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _simpanDraft,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF546E7A), // blue grey
                  foregroundColor: Colors.white, // teks & icon putih
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Simpan Draft',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (v) => v == null || v.isEmpty ? '$label wajib diisi' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
