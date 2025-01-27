# HealthPro
**HealthPro** adalah aplikasi 3-in-1 yang membantu Anda mengelola gaya hidup sehat. Aplikasi ini menyediakan tiga fitur utama: **Activity Tracker**, **Water Reminder**, dan **Food Log**. Dengan berbagai fitur analitik dan pengaturan yang dapat dipersonalisasi, HealthPro bertujuan untuk membantu Anda mencapai tujuan kesehatan secara lebih mudah dan efektif.

## Fitur Utama
### 1. **Activity Tracker**
   - Melacak jumlah langkah harian Anda.
   - Menyediakan analitik dan grafik untuk memonitor progres aktivitas fisik.
### 2. **Water Reminder**
   - Mengingatkan Anda untuk minum air dengan notifikasi yang dapat disesuaikan.
   - Melacak konsumsi air harian dan memberikan laporan progres.
### 3. **Food Log**
   - Mencatat makanan yang Anda konsumsi setiap hari.
   - Fitur AI yang dapat memindai dan menghitung kalori berdasarkan foto makanan yang diambil.
   - Menyediakan analitik kalori harian yang dikonsumsi.
Ketiga fitur diatas dilengkapi statistik dan pengaturan agar dapat lebih dipersonalisasikan.

## Kontribusi
Pembagian tugas dan kontribusi dari setiap anggota tim:
- **William**: Setup activity tracker agar dapat track step dari gerakan device dan pengaturan notifikasi. Membuat fitur food log dengan AI yang sudah disiapkan.
- **Billie**: Mengerjakan hampir semua tampilan aplikasi. Mengerjakan fitur login, register, dan pengeditan informasi pengguna.
- **Joy**: Setup Firebase, Firestore, AI, SQLite, struktur state management (menggunakan BLoC) supaya anggota lain tinggal pakai. Mengerjakan fitur water reminder.
- **Hans**: Mengarahkan desain tampilan dan fitur yang akan dikembangkan. Mengerjakan fitur activity tracker setelah di setup.

Ada kendala teknis: Billie tidak bisa compile APK karena masalah SDK (sudah dicoba semua cara masih tidak bisa). Laptop Hans tidak bisa detect debug via USB dan emulator nya tidak mau jalan meski sudah dicoba betulkan. Jadi supaya semua anggota tetap berkontribusi, mau tidak mau bekerja secara offline. Billie kerja di kampus pakai laptop William, Hans kerja di kampus pakai laptop Joy.

#### Di repository ini ada beberapa branch yang berantakan karena buat backup, jadi kalau mau lihat code yang sudah final tolong cari branch yang push terakhir.
