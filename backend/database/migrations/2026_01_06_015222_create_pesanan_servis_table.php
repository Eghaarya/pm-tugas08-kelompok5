<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('pesanan_servis', function (Blueprint $table) {
            $table->id();
            $table->string('kode_transaksi')->unique();
            $table->decimal('biaya', 12, 2);
            $table->string('nama_pelanggan');
            $table->string('nomor_telp');
            $table->string('foto_awal')->nullable();
            $table->string('foto_progress_1')->nullable();
            $table->string('foto_progress_2')->nullable();
            $table->string('foto_progress_3')->nullable();
            $table->string('foto_progress_4')->nullable();
            $table->string('foto_progress_5')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pesanan_servis');
    }
};
