import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/event_provider.dart';
import '../data/event.dart';
import '../widgets/event_card.dart';
import '../widgets/navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String search = "";
  String selectedCategory = "Tümü";
  String selectedCity = "Tümü";

  final int perPage = 5;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    context.read<EventProvider>().fetchEvents();
  }

  List<Event> getFilteredEvents(List<Event> allEvents) {
    return allEvents.where((event) {
      final matchesSearch =
          event.name.toLowerCase().contains(search.toLowerCase());
      final matchesCategory =
          selectedCategory == "Tümü" || event.category == selectedCategory;
      final matchesCity =
          selectedCity == "Tümü" || event.city == selectedCity;
      return matchesSearch && matchesCategory && matchesCity;
    }).toList();
  }

  List<Event> getCurrentPageEvents(List<Event> filteredEvents) {
    int start = (currentPage - 1) * perPage;
    int end = (start + perPage).clamp(0, filteredEvents.length);
    if (start >= filteredEvents.length) return [];
    return filteredEvents.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final allEvents = context.watch<EventProvider>().events;

    final filteredAll = getFilteredEvents(allEvents);
    final filteredEvents = getCurrentPageEvents(filteredAll);
    final totalPages = (filteredAll.length / perPage).ceil();

    return Scaffold(
      appBar: const NavBar(),
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// 🔍 FİLTRE KARTI
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Etkinlik ara",
                        prefixIcon: const Icon(Icons.search),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) => setState(() {
                        search = value;
                        currentPage = 1;
                      }),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedCategory,
                            decoration: const InputDecoration(
                              labelText: "Kategori",
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            items: ["Tümü", "Müzik", "Komedi", "Tiyatro"]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => setState(() {
                              selectedCategory = value!;
                              currentPage = 1;
                            }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedCity,
                            decoration: const InputDecoration(
                              labelText: "Şehir",
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            items: ["Tümü", "İstanbul", "Ankara", "İzmir"]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => setState(() {
                              selectedCity = value!;
                              currentPage = 1;
                            }),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// EVENT LİSTESİ
              Expanded(
                child: filteredEvents.isEmpty
                    ? const Center(
                        child: Text(
                          "Hiç etkinlik bulunamadı.",
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : ListView.separated(
                        itemCount: filteredEvents.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return EventCard(event: filteredEvents[index]);
                        },
                      ),
              ),

              ///  SAYFALAMA
              if (filteredAll.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: currentPage > 1
                            ? () => setState(() => currentPage--)
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text(
                        "Sayfa $currentPage / $totalPages",
                        style: const TextStyle(fontSize: 14),
                      ),
                      IconButton(
                        onPressed: currentPage < totalPages
                            ? () => setState(() => currentPage++)
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
