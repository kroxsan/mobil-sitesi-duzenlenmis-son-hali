import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../data/event.dart';
import '../providers/auth_provider.dart';

class EventDetailPage extends StatefulWidget {
  final Event event;
  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  int ticketQuantity = 1;
  late Event currentEvent;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentEvent = widget.event;
    fetchEvent();
  }

  Future<void> fetchEvent() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:5151/api/events/${currentEvent.id}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          currentEvent = Event.fromJson(data);
        });
      }
    } catch (_) {}
  }

  Future<void> purchaseTicket() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bilet almak için giriş yapmalısınız')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://localhost:5151/api/tickets"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "eventId": int.parse(currentEvent.id),
          "quantity": ticketQuantity,
        }),
      );

      if (response.statusCode == 201) {
        await fetchEvent();
        setState(() => ticketQuantity = 1);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bilet başarıyla alındı'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final err = jsonDecode(response.body);
        throw Exception(err.toString());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showPurchaseDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Bilet Satın Al'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bilet Fiyatı: ${currentEvent.price.toStringAsFixed(0)} ₺',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: ticketQuantity > 1
                        ? () => setStateDialog(() => ticketQuantity--)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Text(
                    '$ticketQuantity',
                    style: const TextStyle(fontSize: 20),
                  ),
                  IconButton(
                    onPressed: ticketQuantity < currentEvent.capacity
                        ? () => setStateDialog(() => ticketQuantity++)
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Toplam: ${(currentEvent.price * ticketQuantity).toStringAsFixed(0)} ₺',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: currentEvent.capacity <= 0
                  ? null
                  : () {
                      Navigator.pop(context);
                      purchaseTicket();
                    },
              child: const Text('Satın Al'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSoldOut = currentEvent.capacity <= 0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Etkinlik Detayı"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// GÖRSEL
            Image.network(
              currentEvent.imageUrl,
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
            ),

            /// İÇERİK KARTI
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentEvent.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    text: currentEvent.city,
                  ),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text:
                        "${currentEvent.date.day}.${currentEvent.date.month}.${currentEvent.date.year}",
                  ),
                  _InfoRow(
                    icon: Icons.people_outline,
                    text: isSoldOut
                        ? "Tamamen Satıldı"
                        : "Kalan Kapasite: ${currentEvent.capacity}",
                    isWarning: isSoldOut,
                  ),

                  const SizedBox(height: 16),
                  Text(
                    currentEvent.description,
                    style: const TextStyle(height: 1.5),
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          isSoldOut || isLoading ? null : showPurchaseDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSoldOut ? Colors.grey : Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          isSoldOut ? const Text("Tükendi") : const Text("Bilet Al"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 KÜÇÜK BİLGİ SATIRI WIDGET'I
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isWarning;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: isWarning ? Colors.red : Colors.black87,
              fontWeight: isWarning ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
