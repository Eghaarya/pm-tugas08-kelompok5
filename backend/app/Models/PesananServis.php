<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PesananServis extends Model
{
    use HasFactory;

    protected $table = 'pesanan_servis';

    protected $fillable = [
        'kode_transaksi',
        'biaya',
        'nama_pelanggan',
        'nomor_telp',
        'foto_awal',
        'foto_progress_1',
        'foto_progress_2',
        'foto_progress_3',
        'foto_progress_4',
        'foto_progress_5'
    ];
}
