import 'package:admin/main.dart';
import 'package:flutter/material.dart';

class CaterManage extends StatefulWidget {
  const CaterManage({super.key});

  @override
  State<CaterManage> createState() => _CaterManageState();
}

class _CaterManageState extends State<CaterManage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _cat = [];
  List<Map<String, dynamic>> _accepted = [];
  List<Map<String, dynamic>> _rejected = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    fetchData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final response = await supabase.from('tbl_catering').select();

      setState(() {
        _cat.clear();
        _accepted.clear();
        _rejected.clear();

        for (var entry in response) {
          if (entry['cat_status'] == 0) {
            _cat.add(entry); // Pending
          } else if (entry['cat_status'] == 1) {
            _accepted.add(entry); // Accepted
          } else if (entry['cat_status'] == 2) {
            _rejected.add(entry); // Rejected
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  Future<void> accept(String id) async {
    try {
      await supabase.from('tbl_catering').update({'cat_status': 1}).eq('id', id);

      setState(() {
        final entry = _cat.firstWhere((element) => element['id'] == id);
        _cat.remove(entry);
        _accepted.add(entry);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting catering: $e')),
      );
    }
  }

  Future<void> reject(String id) async {
    try {
      await supabase.from('tbl_catering').update({'cat_status': 2}).eq('id', id);

      setState(() {
        final entry = _cat.firstWhere((element) => element['id'] == id);
        _cat.remove(entry);
        _rejected.add(entry);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting catering: $e')),
      );
    }
  }

  void showImage(String image) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF8FAFC),
                      Color(0xFFEFF7FF),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4,
                    child: Image.network(
                      image,
                      height: 500,
                      width: 600,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF065a60),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildTable(String title, List<Map<String, dynamic>> data) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFEFF7FF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF065a60).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  title.contains("Pending")
                      ? Icons.hourglass_empty
                      : title.contains("Accepted")
                          ? Icons.check_circle
                          : Icons.cancel,
                  color: const Color(0xFF065a60),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B263B),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              dataRowHeight: 60,
              columns: [
                const DataColumn(
                  label: Text(
                    "Sl.No",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    "Name",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    "Email",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    "Contact",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    "Address",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    "Proof",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    "Photo",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                if (title == "Pending Catering")
                  const DataColumn(
                    label: Text(
                      "Accept",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                if (title == "Pending Catering")
                  const DataColumn(
                    label: Text(
                      "Reject",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
              ],
              rows: data.asMap().entries.map((entry) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        (entry.key + 1).toString(),
                        style: const TextStyle(color: Color(0xFF1B263B)),
                      ),
                    ),
                    DataCell(
                      Text(
                        entry.value['cat_name'] ?? 'N/A',
                        style: const TextStyle(color: Color(0xFF1B263B)),
                      ),
                    ),
                    DataCell(
                      Text(
                        entry.value['cat_email'] ?? 'N/A',
                        style: const TextStyle(color: Color(0xFF1B263B)),
                      ),
                    ),
                    DataCell(
                      Text(
                        entry.value['cat_contact'] ?? 'N/A',
                        style: const TextStyle(color: Color(0xFF1B263B)),
                      ),
                    ),
                    DataCell(
                      Text(
                        entry.value['cat_address'] ?? 'N/A',
                        style: const TextStyle(color: Color(0xFF1B263B)),
                      ),
                    ),
                    DataCell(
                      GestureDetector(
                        onTap: () {
                          if (entry.value['cat_proof'] != null) {
                            showImage(entry.value['cat_proof']);
                          }
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.amber.withOpacity(0.1),
                          backgroundImage: entry.value['cat_proof'] != null
                              ? NetworkImage(entry.value['cat_proof'])
                              : null,
                          child: entry.value['cat_proof'] == null
                              ? const Icon(
                                  Icons.image_not_supported,
                                  color: Color(0xFF64748B),
                                  size: 20,
                                )
                              : null,
                        ),
                      ),
                    ),
                    DataCell(
                      GestureDetector(
                        onTap: () {
                          if (entry.value['cat_img'] != null) {
                            showImage(entry.value['cat_img']);
                          }
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.amber.withOpacity(0.1),
                          backgroundImage: entry.value['cat_img'] != null
                              ? NetworkImage(entry.value['cat_img'])
                              : null,
                          child: entry.value['cat_img'] == null
                              ? const Icon(
                                  Icons.image_not_supported,
                                  color: Color(0xFF64748B),
                                  size: 20,
                                )
                              : null,
                        ),
                      ),
                    ),
                    if (title == "Pending Catering")
                      DataCell(
                        GestureDetector(
                          onTap: () {
                            accept(entry.value['id']);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF065a60).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.amber.withOpacity(0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Color(0xFF065a60),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    if (title == "Pending Catering")
                      DataCell(
                        GestureDetector(
                          onTap: () {
                            reject(entry.value['id']);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.redAccent.withOpacity(0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: fetchData,
        color: const Color(0xFF065a60),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF065a60).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: Color(0xFF065a60),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Catering Management',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B263B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage pending, accepted, and rejected catering services',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 24),
              buildTable("Pending Catering", _cat),
              buildTable("Accepted Catering", _accepted),
              buildTable("Rejected Catering", _rejected),
            ],
          ),
        ),
      ),
    );
  }
}