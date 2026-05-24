import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ================= MODEL =================
class Catatan {
  final String judul;
  final String isi;
  final String kategori;
  final DateTime dibuatPada;

  Catatan({
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.dibuatPada,
  });
}

// ================= APP =================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Mahasiswa',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),

      initialRoute: '/',

      routes: {
        '/': (context) => const HomePage(),
      },

      onGenerateRoute: (settings) {

        switch (settings.name) {

          case '/tambah':
            return MaterialPageRoute(
              builder: (_) => const TambahCatatanPage(),
            );

          case '/detail':

            final catatan =
            settings.arguments as Catatan;

            return MaterialPageRoute(
              builder: (_) => DetailCatatanPage(
                catatan: catatan,
              ),
            );
        }

        return null;
      },
    );
  }
}

// ================= HOME PAGE =================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // ================= DATA =================
  final List<Catatan> _catatan = [

    Catatan(
      judul: 'Belajar Flutter',
      isi:
      'Mempelajari Stateful Widget, Form, dan Navigation.',
      kategori: 'Kuliah',
      dibuatPada: DateTime.now(),
    ),
  ];

  // ================= FILTER =================
  String _filterKategori = 'Semua';

  // ================= TAMBAH CATATAN =================
  Future<void> _bukaTambahCatatan() async {

    final hasil =
    await Navigator.pushNamed(
      context,
      '/tambah',
    );

    if (hasil is Catatan) {

      setState(() {
        _catatan.add(hasil);
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Catatan "${hasil.judul}" ditambahkan',
          ),
        ),
      );
    }
  }

  // ================= FORMAT TANGGAL =================
  String _formatTanggal(DateTime t) {
    return '${t.day}/${t.month}/${t.year}';
  }

  @override
  Widget build(BuildContext context) {

    // ================= FILTER DATA =================
    final hasilFilter =
    _filterKategori == 'Semua'
        ? _catatan
        : _catatan
        .where(
          (c) =>
      c.kategori ==
          _filterKategori,
    )
        .toList();

    return Scaffold(

      // ================= APPBAR =================
      appBar: AppBar(
        title:
        const Text('Catatan Mahasiswa'),

        actions: [

          Padding(
            padding:
            const EdgeInsets.only(
              right: 12,
            ),

            child:
            DropdownButton<String>(

              value: _filterKategori,

              underline:
              const SizedBox(),

              items: const [

                DropdownMenuItem(
                  value: 'Semua',
                  child: Text('Semua'),
                ),

                DropdownMenuItem(
                  value: 'Kuliah',
                  child: Text('Kuliah'),
                ),

                DropdownMenuItem(
                  value: 'Tugas',
                  child: Text('Tugas'),
                ),

                DropdownMenuItem(
                  value: 'Pribadi',
                  child: Text('Pribadi'),
                ),

                DropdownMenuItem(
                  value: 'Lainnya',
                  child: Text('Lainnya'),
                ),
              ],

              onChanged: (v) {

                setState(() {
                  _filterKategori = v!;
                });
              },
            ),
          ),
        ],
      ),

      // ================= BODY =================
      body: hasilFilter.isEmpty

          ? const _EmptyState()

          : ListView.builder(

        itemCount:
        hasilFilter.length,

        itemBuilder:
            (context, i) {

          final c =
          hasilFilter[i];

          return Card(
            margin:
            const EdgeInsets.all(
              8,
            ),

            child: ListTile(

              leading:
              const Icon(
                Icons.note,
              ),

              title:
              Text(c.judul),

              subtitle: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [

                  Text(c.kategori),

                  Text(
                    _formatTanggal(
                      c.dibuatPada,
                    ),
                  ),
                ],
              ),

              // ================= DETAIL =================
              onTap: () {

                Navigator.pushNamed(
                  context,
                  '/detail',
                  arguments: c,
                );
              },

              // ================= DELETE =================
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),

                onPressed: () {

                  setState(() {
                    _catatan.remove(c);
                  });
                },
              ),
            ),
          );
        },
      ),

      // ================= FAB =================
      floatingActionButton:
      FloatingActionButton(
        onPressed:
        _bukaTambahCatatan,

        child:
        const Icon(Icons.add),
      ),
    );
  }
}

// ================= EMPTY STATE =================
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {

    return const Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [

          Icon(
            Icons.note_alt_outlined,
            size: 80,
            color: Colors.grey,
          ),

          SizedBox(height: 16),

          Text(
            'Belum ada catatan',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ================= TAMBAH PAGE =================
class TambahCatatanPage
    extends StatefulWidget {

  const TambahCatatanPage({
    super.key,
  });

  @override
  State<TambahCatatanPage>
  createState() =>
      _TambahCatatanPageState();
}

class _TambahCatatanPageState
    extends State<TambahCatatanPage> {

  final _formKey =
  GlobalKey<FormState>();

  final _judulCtrl =
  TextEditingController();

  final _isiCtrl =
  TextEditingController();

  String _kategori = 'Kuliah';

  final _kategoriOpsi = const [
    'Kuliah',
    'Tugas',
    'Pribadi',
    'Lainnya',
  ];

  @override
  void dispose() {

    _judulCtrl.dispose();
    _isiCtrl.dispose();

    super.dispose();
  }

  // ================= SIMPAN =================
  void _simpan() {

    if (!_formKey.currentState!
        .validate()) return;

    final catatanBaru = Catatan(
      judul:
      _judulCtrl.text.trim(),

      isi:
      _isiCtrl.text.trim(),

      kategori: _kategori,

      dibuatPada:
      DateTime.now(),
    );

    Navigator.pop(
      context,
      catatanBaru,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
        const Text(
          'Tambah Catatan',
        ),
      ),

      body: Form(
        key: _formKey,

        child: ListView(
          padding:
          const EdgeInsets.all(16),

          children: [

            // ================= JUDUL =================
            TextFormField(
              controller:
              _judulCtrl,

              decoration:
              const InputDecoration(
                labelText: 'Judul',
                prefixIcon:
                Icon(Icons.title),
                border:
                OutlineInputBorder(),
              ),

              validator: (v) {

                if (v == null ||
                    v.trim().isEmpty) {
                  return 'Judul wajib diisi';
                }

                if (v.trim().length < 3) {
                  return 'Minimal 3 karakter';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // ================= KATEGORI =================
            DropdownButtonFormField<String>(

              value: _kategori,

              decoration:
              const InputDecoration(
                labelText: 'Kategori',
                prefixIcon:
                Icon(Icons.category),
                border:
                OutlineInputBorder(),
              ),

              items: _kategoriOpsi
                  .map(
                    (k) =>
                    DropdownMenuItem(
                      value: k,
                      child: Text(k),
                    ),
              )
                  .toList(),

              onChanged: (v) {

                if (v != null) {

                  setState(() {
                    _kategori = v;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // ================= ISI =================
            TextFormField(

              controller: _isiCtrl,

              maxLines: 5,

              decoration:
              const InputDecoration(
                labelText: 'Isi',
                prefixIcon:
                Icon(Icons.notes),
                border:
                OutlineInputBorder(),
              ),

              validator: (v) {

                if (v == null ||
                    v.trim().isEmpty) {
                  return 'Isi wajib diisi';
                }

                return null;
              },
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _simpan,

              icon:
              const Icon(Icons.save),

              label:
              const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= DETAIL PAGE =================
class DetailCatatanPage
    extends StatelessWidget {

  final Catatan catatan;

  const DetailCatatanPage({
    super.key,
    required this.catatan,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
        const Text(
          'Detail Catatan',
        ),
      ),

      body: SingleChildScrollView(

        padding:
        const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            Text(
              catatan.judul,

              style:
              const TextStyle(
                fontSize: 24,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Chip(
              label:
              Text(catatan.kategori),
            ),

            const Divider(height: 32),

            Text(
              catatan.isi,

              style:
              const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },

              icon:
              const Icon(Icons.arrow_back),

              label: const Text(
                'Kembali ke Daftar',
              ),
            ),
          ],
        ),
      ),
    );
  }
}