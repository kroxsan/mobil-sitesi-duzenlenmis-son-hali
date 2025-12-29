import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  List<dynamic> tickets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTickets();
  }

  Future<void> loadTickets() async {
    setState(() => isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("http://localhost:5151/api/tickets/my-tickets"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final loadedTickets = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          tickets = loadedTickets;
          isLoading = false;
        });
      } else {
        throw Exception('Biletler yüklenemedi');
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteTicket(int ticketId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    try {
      final response = await http.delete(
        Uri.parse("http://localhost:5151/api/tickets/$ticketId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 204) {
        loadTickets();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Biletlerim'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tickets.isEmpty
              ? const _EmptyState()
              : RefreshIndicator(
                  onRefresh: loadTickets,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      final event = ticket['event'];
                      final purchaseDate =
                          DateTime.parse(ticket['purchaseDate']);

                      final location = (event['location'] ?? '').isEmpty
                          ? '${event['city'] ?? 'Bilinmeyen Şehir'}'
                          : event['location'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// GÖRSEL
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                event['imageUrl'] ??
                                    'https://picsum.photos/400/200',
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 150,
                                  color: Colors.grey[300],
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.broken_image),
                                ),
                              ),
                            ),

                            /// İÇERİK
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event['name'] ?? 'İsimsiz Etkinlik',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  _InfoRow(
                                    icon: Icons.location_on_outlined,
                                    text: location,
                                  ),
                                  _InfoRow(
                                    icon: Icons.calendar_today_outlined,
                                    text: DateTime.parse(event['date'])
                                        .toString()
                                        .split(' ')[0],
                                  ),

                                  const Divider(height: 24),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _StatColumn(
                                        label: 'Bilet Sayısı',
                                        value: '${ticket['quantity']} Adet',
                                      ),
                                      _StatColumn(
                                        label: 'Toplam Tutar',
                                        value:
                                            '${ticket['totalPrice'].toStringAsFixed(0)} ₺',
                                        highlight: true,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),
                                  Text(
                                    'Satın alma: ${purchaseDate.day}.${purchaseDate.month}.${purchaseDate.year}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),

                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 44,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.cancel),
                                      label: const Text('Bileti İptal Et'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(color: Colors.red),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title:
                                                const Text('Bilet İptali'),
                                            content: const Text(
                                              'Bu bileti iptal etmek istediğinize emin misiniz?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Vazgeç'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  deleteTicket(ticket['id']);
                                                },
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                ),
                                                child:
                                                    const Text('İptal Et'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

/// 🔹 BOŞ DURUM
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.confirmation_number_outlined,
              size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Henüz biletiniz yok',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// 🔹 KÜÇÜK SATIR
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔹 İSTATİSTİK
class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _StatColumn({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: highlight ? Colors.black : Colors.black87,
          ),
        ),
      ],
    );
  }
}
