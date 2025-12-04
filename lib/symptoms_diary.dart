import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../colors.dart';
import 'components/symptoms/add_symptoms.dart';
import 'components/symptoms/diary_card.dart';

class SymptomsDiaryPage extends StatefulWidget {
  const SymptomsDiaryPage({super.key});

  @override
  _SymptomsDiaryPageState createState() => _SymptomsDiaryPageState();
}

class _SymptomsDiaryPageState extends State<SymptomsDiaryPage> {
  late Box symptomsBox;
  List<Map<String, dynamic>> diary = [];
  String _selectedFilter = 'All'; // 'All', 'Resolved', 'Unresolved'

  @override
  void initState() {
    super.initState();
    symptomsBox = Hive.box('symptoms');
    _loadDiary();
    symptomsBox.listenable().addListener(_loadDiary); // auto-refresh on changes
  }

  void _loadDiary() {
    final entries = symptomsBox.get('entries', defaultValue: []);
    setState(() {
      // Load and sort by created_at (newest first)
      diary = entries
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
          .toList()
        ..sort((a, b) {
          try {
            final dateA = DateTime.parse(a['created_at'] ?? '');
            final dateB = DateTime.parse(b['created_at'] ?? '');
            return dateB.compareTo(dateA); // Descending order (newest first)
          } catch (e) {
            return 0;
          }
        });
    });
  }

  List<Map<String, dynamic>> _getFilteredDiary() {
    switch (_selectedFilter) {
      case 'Resolved':
        return diary.where((item) => item['resolved'] == true).toList();
      case 'Unresolved':
        return diary.where((item) => item['resolved'] != true).toList();
      default:
        return diary;
    }
  }

  void _openDiaryForm({Map<String, dynamic>? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SymptomsDiaryForm(
        existingSymptom: existing,
        onSaved: _loadDiary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredDiary = _getFilteredDiary();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text("Symptoms Diary",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        toolbarHeight: 80,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  'Filter: ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', diary.length),
                        SizedBox(width: 8),
                        _buildFilterChip(
                          'Resolved',
                          diary.where((item) => item['resolved'] == true).length,
                        ),
                        SizedBox(width: 8),
                        _buildFilterChip(
                          'Unresolved',
                          diary.where((item) => item['resolved'] != true).length,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Diary list
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: filteredDiary.isEmpty
                  ? _emptyState()
                  : _buildDiaryList(filteredDiary),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGreen,
        onPressed: () => _openDiaryForm(),
        child: const Icon(
          Icons.edit_note,
          size: 30,
          color: AppColors.mintGreen,
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.primaryGreen.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primaryGreen,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryGreen : AppColors.deepGreen,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _emptyState() {
    String message;
    switch (_selectedFilter) {
      case 'Resolved':
        message = "No resolved symptoms yet";
        break;
      case 'Unresolved':
        message = "No unresolved symptoms";
        break;
      default:
        message = "No symptoms recorded yet";
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_outlined, color: AppColors.primaryGreen, size: 60),
          SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          if (_selectedFilter == 'All') ...[
            SizedBox(height: 4),
            Text(
              "Tap the button below to add one",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiaryList(List<Map<String, dynamic>> items) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: 15),
      itemBuilder: (context, index) {
        final item = items[index];
        return DiaryCard(
          item: item,
          onEdit: () => _openDiaryForm(existing: item),
          onUpdate: _loadDiary, // Pass the refresh callback
        );
      },
    );
  }

  @override
  void dispose() {
    symptomsBox.listenable().removeListener(_loadDiary);
    super.dispose();
  }
}