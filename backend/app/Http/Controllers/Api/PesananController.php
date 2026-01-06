<?php

namespace App\Http\Controllers\Api;

use Illuminate\Support\Str;
use Illuminate\Http\Request;
use App\Models\PesananServis;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Storage;

class PesananController extends Controller
{
    /**
     * READ: Ambil semua data pesanan
     */
    public function index()
    {
        return response()->json([
            'success' => true,
            'total' => PesananServis::count(),
            'data' => PesananServis::all()->map(function ($item) {
                return array_merge($item->toArray(), [
                    'foto_awal_url' => $item->foto_awal ? asset('storage/' . $item->foto_awal) : null,
                    'foto_progress_1_url' => $item->foto_progress_1 ? asset('storage/' . $item->foto_progress_1) : null,
                    'foto_progress_2_url' => $item->foto_progress_2 ? asset('storage/' . $item->foto_progress_2) : null,
                    'foto_progress_3_url' => $item->foto_progress_3 ? asset('storage/' . $item->foto_progress_3) : null,
                    'foto_progress_4_url' => $item->foto_progress_4 ? asset('storage/' . $item->foto_progress_4) : null,
                    'foto_progress_5_url' => $item->foto_progress_5 ? asset('storage/' . $item->foto_progress_5) : null,
                ]);
            })
        ]);
    }

    /**
     * BACKUP + UPLOAD FOTO
     */
    public function backup(Request $request)
    {
        $request->validate([
            'data' => 'required|string',

            'foto_awal' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
            'foto_progress_1' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
            'foto_progress_2' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
            'foto_progress_3' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
            'foto_progress_4' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
            'foto_progress_5' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        // decode JSON string
        $data = json_decode($request->data, true);

        if (!$data || empty($data['kode_transaksi'])) {
            return response()->json([
                'success' => false,
                'message' => 'Format data tidak valid'
            ], 422);
        }

        // UPSERT DATA
        $pesanan = PesananServis::updateOrCreate(
            ['kode_transaksi' => $data['kode_transaksi']],
            [
                'biaya' => $data['biaya'] ?? 0,
                'nama_pelanggan' => $data['nama_pelanggan'] ?? null,
                'nomor_telp' => $data['nomor_telp'] ?? null,
            ]
        );

        $fotoFields = [
            'foto_awal',
            'foto_progress_1',
            'foto_progress_2',
            'foto_progress_3',
            'foto_progress_4',
            'foto_progress_5',
        ];

        foreach ($fotoFields as $field) {
            if ($request->hasFile($field)) {

                // hapus foto lama
                if ($pesanan->$field && Storage::disk('public')->exists($pesanan->$field)) {
                    Storage::disk('public')->delete($pesanan->$field);
                }

                $extension = $request->file($field)->extension();

                // nama file pakai kode transaksi
                $filename = $data['kode_transaksi']
                    . '_' . $field
                    . '_' . time()
                    . '.' . $extension;

                // simpan ke folder uploads
                $path = $request->file($field)->storeAs(
                    'uploads',
                    $filename,
                    'public'
                );

                $pesanan->$field = $path;
            }
        }

        $pesanan->save();

        return response()->json([
            'success' => true,
            'message' => 'Backup & upload foto berhasil',
            'data' => $pesanan
        ]);
    }
}
