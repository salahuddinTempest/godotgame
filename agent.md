# 📁 AGENT.MD — Sistem Pembagian Tugas (Multi-Agent Workflow)

Dokumen ini mengatur peran, batasan, dan tanggung jawab dari setiap komponen dalam ekosistem pengembangan proyek game ini. Tujuannya adalah untuk mencegah tumpang tindih fungsi dan memastikan kolaborasi yang efisien.

---

## 👥 Matriks Peran & Tanggung Jawab

| Komponen | Peran Utama | Fokus Utama | Output |
| :--- | :--- | :--- | :--- |
| **AI Agent** | Otak Arsitektur & Strategi | Analisis, Desain Kode, & *Troubleshooting* | Logika GDScript, Skrip Python, Dokumentasi |
| **Antigravity** | Eksekutor & Jembatan Sistem | Otomasi, Manajemen *State*, & Sinkronisasi | *Build Automation*, Validasi Aset, Integrasi Git |
| **Open Code** | Ruang Kerja & Editor Visual | Menulis Kode, Penataan Struktur, & Refactoring | File `.gd`, `.json`, `.cfg` yang Bersih |

---

## 🛠️ Detail Tugas Masing-Masing Komponen

### 1. 🤖 AI Agent (Teman Vibe Coding Anda)
Agent bertindak sebagai arsitek tingkat tinggi dan konsultan teknis utama Anda. Agent tidak mengeksekusi kode secara langsung di mesin, melainkan merancang solusinya.

* **Tugas Spesifik:**
    * **Arsitektur Kode:** Merancang struktur logika game (misalnya, sistem *State Machine* untuk AI musuh atau manajemen data *inventory*).
    * **Debugging Tingkat Lanjut:** Menganalisis log error yang Anda salin dari terminal Git Bash dan memberikan solusi perbaikan yang akurat.
    * **Generator Dokumentasi:** Menulis dan memperbarui file panduan seperti `README.md`, `.gitignore`, dan dokumen teknis lainnya.
    * **Optimasi Algoritma:** Mengoptimalkan kode GDScript agar berjalan lebih ringan dan efisien di Godot Engine.

### 2. 🌌 Antigravity (Runtime & Automation Runner)
Antigravity bertindak sebagai mesin penggerak di latar belakang yang menghubungkan ide dari Agent dengan eksekusi di sistem operasi.

* **Tugas Spesifik:**
    * **Otomasi Tugas (Build Scripts):** Menjalankan skrip Python untuk melakukan *export* otomatis, manajemen aset, atau pembersihan *cache* editor Godot.
    * **Manajemen Linting:** Memeriksa keselarasan sintaksis kode sebelum dimasukkan ke dalam repositori Git.
    * **Pengawasan Lingkungan (Environment Monitoring):** Memastikan terminal Git Bash, *environment variables* (PATH), dan konfigurasi profil seperti `~/.bashrc` berjalan dengan harmonis.
    * **Manajemen Dependensi:** Mengelola pustaka atau *plugin* pihak ketiga yang dibutuhkan oleh Godot Engine.

### 3. 📝 Open Code (The Core Workspace)
Open Code adalah tempat di mana Anda dan AI berinteraksi langsung dengan file fisik proyek. Ini adalah kanvas tempat kode ditulis dan ditata.

* **Tugas Spesifik:**
    * **Penulisan Kode (Code Authoring):** Menyediakan lingkungan teks editor yang cepat dan ringan untuk mengetik skrip `.gd` (GDScript).
    * **Struktur Folder & Navigasi:** Membantu Anda melihat hierarki proyek secara visual (seperti folder `src/`, `assets/`, dan `tools/`).
    * **Global Search & Replace:** Memudahkan pencarian fungsi atau variabel tertentu di seluruh file proyek dengan cepat ketika terjadi perubahan besar (*refactoring*).
    * **Manajemen Snippet:** Menyimpan templat kode yang sering digunakan agar proses *coding* menjadi lebih instan.

---

## 🔄 Alur Kerja Kolaborasi (Workflow Loop)

1. **Tahap Ide (Agent):** Anda berdiskusi dengan **Agent** untuk merancang fitur baru. Agent memberikan draf struktur kode dan algoritma.
2. **Tahap Implementasi (Open Code):** Anda membuka **Open Code** untuk menyalin, mengedit, dan merapikan skrip GDScript tersebut ke dalam folder proyek.
3. **Tahap Validasi & Otomasi (Antigravity):** **Antigravity** menjalankan skrip pengujian atau otomasi lewat terminal untuk memastikan tidak ada file yang rusak.
4. **Tahap Eksekusi (Godot):** Anda menjalankan perintah `godot --editor` melalui Git Bash untuk melihat hasilnya langsung di engine.

---

> 💡 **Prinsip Utama:**
> *Jangan biarkan Open Code memikirkan algoritma, jangan biarkan Agent menulis file secara acak tanpa struktur Open Code, dan pastikan Antigravity yang menjaga agar semua terminal dan otomatisasi tetap menyala dengan lancar.*