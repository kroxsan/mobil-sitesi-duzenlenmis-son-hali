import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../providers/auth_provider.dart';
import '../data/event.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _cityController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _capacityController = TextEditingController();
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();

  String? editingEventId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();

      if (!authProvider.isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      if (!authProvider.isAdmin) {
        Navigator.pushReplacementNamed(context, '/');
        return;
      }

      context.read<EventProvider>().fetchEvents();
    });
  }

  void _loadEventToForm(Event event) {
    _nameController.text = event.name;
    _descriptionController.text = event.description;
    _categoryController.text = event.category;
    _cityController.text = event.city;
    _priceController.text = event.price.toString();
    _imageUrlController.text = event.imageUrl;
    _capacityController.text = event.capacity.toString();
    _dateController.text = event.date.toIso8601String().split('T')[0];
    _locationController.text = event.location;
    editingEventId = event.id;
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _categoryController.clear();
    _cityController.clear();
    _priceController.clear();
    _imageUrlController.clear();
    _capacityController.clear();
    _dateController.clear();
    _locationController.clear();
    editingEventId = null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<EventProvider>();

    final event = Event(
      id: editingEventId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: _descriptionController.text,
      category: _categoryController.text,
      city: _cityController.text,
      price: double.tryParse(_priceController.text) ?? 0,
      date: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
      imageUrl: _imageUrlController.text.isNotEmpty
          ? _imageUrlController.text
          : "https://picsum.photos/400/200",
      location: _locationController.text.isNotEmpty
          ? _locationController.text
          : "Belirtilmemiş",
      capacity: int.tryParse(_capacityController.text) ?? 100,
    );

    if (editingEventId != null) {
      await provider.updateEvent(event);
    } else {
      await provider.addEvent(event);
    }

    _clearForm();
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Admin Paneli"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// FORM KARTI
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Etkinlik Yönetimi",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _field(_nameController, "Etkinlik Adı", required: true),
                      _field(_descriptionController, "Açıklama", maxLines: 3),
                      _field(_categoryController, "Kategori"),
                      _field(_cityController, "Şehir"),
                      _field(_locationController, "Konum"),
                      _field(_priceController, "Fiyat",
                          keyboard: TextInputType.number),
                      _field(_capacityController, "Kapasite",
                          keyboard: TextInputType.number, required: true),
                      _field(_dateController, "Tarih (YYYY-MM-DD)",
                          keyboard: TextInputType.datetime, required: true),
                      _field(_imageUrlController, "Görsel URL"),

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: Text(
                            editingEventId != null
                                ? "Etkinliği Güncelle"
                                : "Etkinlik Ekle",
                          ),
                        ),
                      ),
                      if (editingEventId != null)
                        TextButton(
                          onPressed: _clearForm,
                          child: const Text("İptal"),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// LİSTE
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Etkinlik Listesi",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),

                    eventProvider.events.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text("Henüz etkinlik yok."),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemCount: eventProvider.events.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 16),
                            itemBuilder: (context, index) {
                              final event =
                                  eventProvider.events[index];
                              return Row(
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    child: Image.network(
                                      event.imageUrl,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          Container(
                                        width: 56,
                                        height: 56,
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.name,
                                          style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.w500),
                                        ),
                                        Text(
                                          "${event.city} • ${event.date.toLocal().toString().split(' ')[0]}",
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _loadEventToForm(event),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        eventProvider.deleteEvent(event.id),
                                  ),
                                ],
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool required = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        validator: required
            ? (v) => v == null || v.isEmpty ? "Zorunlu alan" : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
