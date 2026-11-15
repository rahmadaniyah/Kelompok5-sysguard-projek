# SysGuard Project — Kelompok 5
**Monitoring kondisi sistem/layanan serta Backup dan Restore**

## 1. Nama Proyek dan Identitas Kelompok
* **Nama Proyek:** SysGuard Project (Sistem/Layanan Backup, Restore, dan Monitoring)
* **Mata Kuliah:** Praktikum Sistem Operasi
* **Tahap:** Proyek Akhir 
* **Kelas:** D
* **Kelompok:**  Kelompok 5

**Anggota Kelompok:**
1. Fitri Rahmadaniyah - 2510501124
2. Muhammad Alfridho Pasha - 2510501118
3. Nabiel Prabaswara - M.M.B 2510501129
4. Nilam Rahma Sari - 2510501114

## 2. Tujuan Proyek
Proyek ini bertujuan membangun sistem otomasi administrasi server Linux berbasis Bash Scripting dan Docker yang aman, terukur, dan terintegrasi]. Pengujian mencakup pembangunan layanan web terisolasi di dalam container dengan konfigurasi persistensi data, penerapan akses aman (pengaturan ownership, permission, dan akses SSH/SFTP), pembatasan sumber daya (resource limit CPU dan memori), pencadangan (backup) direktori secara terkompresi dengan validasi kapasitas penyimpanan, pemulihan data (restore) yang tervalidasi, serta pemantauan metrik performa sistem dan log container secara real-time.
Proyek ini juga bertujuan menguji penanganan kondisi gagal (seperti direktori sumber yang tidak ditemukan, kapasitas penyimpanan tidak mencukupi, arsip cadangan yang tidak valid, maupun skenario akses ditolak), melakukan pemulihan data (recovery), dan memastikan seluruh tindakan administrasi tidak merusak layanan container yang sedang berjalan.

## 3. Arsitektur dan Pembagian Komponen (Host vs Container)
Sistem SysGuard dibagi menjadi dua lingkungan utama yang saling terintegrasi, yaitu lingkungan **Host** (Ubuntu Server) dan lingkungan **Container** (Docker):
* **Komponen Host:** Bagian ini berjalan langsung di komputer atau server utama (Ubuntu) untuk mengatur jalannya sistem dan menyimpan file cadangan. Di sisi host, dapat menjalankan skrip `backup_restore.sh` untuk mengecek sisa ruang penyimpanan, membungkus folder data menjadi file cadangan `.tar.gz`, dan mengembalikan data (restore) lengkap dengan pengaturan hak aksesnya (ownership dan permission). Selain itu, skrip `monitoring.sh` juga dijalankan di host untuk mengecek pemakaian CPU, RAM, dan disk secara terus-menerus. Semua file cadangan disimpan di folder `~/backup_sistem/` di luar container supaya datanya tetap aman meskipun container dimatikan atau dihapus. Pengaturan keamanan akses seperti grup `docker` dan koneksi SSH/SFTP juga diatur di bagian host ini.
* **Komponen Container:** Bagian ini berfungsi sebagai tempat menjalankan aplikasi web secara terpisah di dalam Docker. Lewat file `dockerfile` dan `docker-compose.yml`, sistem membuat image bernama `sysguard-web` lalu menjalankan container `sysguard-app` yang berisi web server Nginx sederhana berbasis Alpine Linux. Container ini memakai jaringan internal sendiri dan diberi batasan pemakaian CPU dan RAM (resource limit) supaya tidak membuat komputer host menjadi berat, serta dihubungkan dengan volume penyimpanan agar data web tidak hilang saat container di-restart.

## 4. Prasyarat
* Sistem operasi Linux Ubuntu. 
* Docker engine dan docker compose plugin sudah terinstal dan berjalan aktif. 
* Utilitas standar linux seperti (tar, gzip, curl, awk, dan git).
* Proses simulasi yang dibuat dan dimiliki oleh kelompok.

## 5. Cara Menjalankan Sistem
* Buka terminal Ubuntu server 
* Clone repositori dan masuk ke direktori proyek
* Sebelum menjalankan proyek pastikan daemon docker aktif 
* Bangun image dan jalankan container 
* Berikan izin eksekusi pada skrip `backup_restore.sh` dan `monitoring.sh`
* Terapkan pengaturan ownership, permission grup `docker`, serta konfigurasi akses aman SSH/SFTP pada direktori target
* Jalankan skrip `backup_restore.sh` untuk melakukan pencadangan (Menu 1) atau pemulihan data (Menu 2) dan keluar dari program (Menu 3)
* Jalankan skrip `monitoring.sh` untuk memantau penggunaan CPU, memori, dan disk secara real-time, serta pantau log internal container

## 6. Cara Melakukan Pengujian
Pengujian dilakukan berdasarkan skenario berhasil dan gagal pada setiap modul. Skenario pengujian meliputi: 
* Pembangunan image, aktivasi container, persistensi volume, dan pembatasan resource limit (CPU & Memory)
* Penerapan akses aman (ownership, permission, dan skenario akses diizinkan/ditolak via SSH/SFTP)
* Pengujian backup data beserta validasi kapasitas penyimpanan
* Pengujian kondisi gagal pada input backup dan file restore yang tidak ditemukan
* Pengujian restore data dan verifikasi integritas file serta hak aksesnya
* Pengujian integrasi layanan web container dan pemantauan log container
* Pengujian pemantauan resource sistem secara real-time melalui modul monitoring
* Pembersihan (cleanup) hasil simulasi setelah pengujian

## 7. Hasil yang Diharapkan
Hasil yang diharapkan oleh kelompok kami  dari pengujian proyek ini: 
* Container layanan web aktif (`Up`), terisolasi, menggunakan volume persisten, dan mematuhi batas resource limit
* Pengaturan ownership, permission, dan akses SSH/SFTP berjalan sesuai otorisasi 
* Proses backup memvalidasi ruang penyimpanan dan menghasilkan arsip `.tar.gz` yang valid
* Proses restore memulihkan seluruh file dengan ukuran utuh serta permission dan grup `docker` yang sesuai
* Kondisi gagal pada input ditangani dengan pesan error yang jelas tanpa merusak sistem
* Modul monitoring menampilkan status CPU, RAM, dan Disk secara berkala tanpa mengganggu layanan container
* Direktori simulasi pengujian dapat dibersihkan setelah pengujian selesai

## 8. Cara Memverifikasi Hasil
verifikasi dilakukan dengan membandingkan expected result dan hasil aktual pada setiap skenario pengujian. Pemeriksaan meliputi: 
* Status container, alokasi resource limit, respon HTTP layanan web, dan log container
* Hak akses SSH/SFTP serta ownership dan permission direktori
* Keberadaan dan ukuran arsip `.tar.gz` hasil backup
* Keutuhan ukuran file, permission (`-rwxrwxr-x`), dan kepemilikan grup (`docker`) pada hasil restore 
* Output metrik CPU, RAM, dan Disk pada modul monitoring
Bukti/dokumentasi berupa output, teks, dan screenshot pendukung yang dirangkum dalam laporan pengujian.pdf

## 9. Risiko dan Solusi
Risiko pengujian meliputi kesalahan pemilihan direktori tujuan restore yang dapat menimpa file aktif, kegagalan akses karena kesalahan ownership/permission, pembengkakan penggunaan resource container jika limit tidak aktif, serta tertinggalnya file sisa simulasi di repositori. 
Untuk mengurangi risiko, kelompok memvalidasi lokasi sumber dan arsip sebelum ekstraksi, mengarahkan hasil restore ke folder berstempel waktu (`restore_YYYYMMDD_HHMMSS`), menerapkan pembatasan resource pada container, dan melakukan cleanup setelah pengujian selesai

## 10. Cleanup dan Rollback
Setelah pengujian selesai, kelompok melakukan langkah berikut: 
* Menghapus direktori hasil simulasi restore sementara (`restore_*`) pada folder `source/docker/`
* Menghentikan skrip monitoring yang sedang berjalan dan memastikan tidak ada proses latar belakang yang tertinggal. 
* Menghentikan layanan container sementara jika sesi pengujian telah selesai
* Memastikan struktur kode sumber pada repositori tetap bersih dan tidak terdampak
Jika terjadi kesalahan selama pengujian, kelompok memulihkan data dari arsip cadangan stabil terakhir di `~/backup_sistem/`, membangun ulang container dari kondisi bersih, dan memverifikasi kembali seluruh layanan


