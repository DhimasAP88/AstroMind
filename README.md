# AstroMind: Akademi Penjelajah Galaksi (EdTech Android Game)

Game edukasi mobile Android berbasis **Flutter** untuk melatih **Fokus**, **Berhitung Cepat**, dan **Daya Ingat (Working Memory)** bagi anak dan remaja usia **7 - 15 tahun**.

## Fitur Utama
1. **3 Tingkat Kesulitan Adaptif:**
   - **EASY (7 - 9 Tahun):** Fokus visual dasar, penjumlahan/pengurangan, dan matriks memori 3x3.
   - **MEDIUM (10 - 12 Tahun):** Fokus warna tinta, perkalian & operasi campuran, serta matriks memori 4x4.
   - **HARD (13 - 15 Tahun):** *Stroop Effect* (Teks vs Warna Tinta), operasi matematika 3 suku & kuadrat, serta matriks memori 4x4 kecepatan tinggi.
2. **Penyimpanan Skor Permanen (100% Offline):**
   - Menggunakan `shared_preferences` untuk menyimpan:
     - Total Kristal Energi (`totalEnergyShards`) & Pangkat Kadet (`Rookie` hingga `Commander`)
     - Jumlah misi selesai (`missionsCompleted`)
     - Tingkat kesulitan terakhir yang dipilih (`lastSelectedDifficulty`)
     - **High Score (Rekor Tertinggi)** untuk masing-masing kombinasi *Mini-Game* dan *Difficulty* (9 slot rekor terpisah).

## Cara Menjalankan Proyek
1. Pastikan Flutter SDK telah terpasang di komputer Anda.
2. Buka folder proyek ini sebagai *active workspace*:
   ```bash
   cd /Users/Administrator/.gemini/antigravity/scratch/astromind_edtech
   ```
3. Jika folder platform `android/` belum tergenerasi, jalankan perintah inisialisasi platform sekali:
   ```bash
   flutter create . --platforms=android
   ```
4. Unduh *dependencies* (`shared_preferences`) dan jalankan di perangkat/emulator Android:
   ```bash
   flutter pub get
   flutter run
   ```
