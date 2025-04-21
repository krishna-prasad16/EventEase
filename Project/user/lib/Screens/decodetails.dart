import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user/Screens/more_decorations.dart';
import 'package:user/Screens/sendrqst.dart';

class Decodetails extends StatefulWidget {
  final Map<String, dynamic> decoration;

  const Decodetails({super.key, required this.decoration});

  @override
  State<Decodetails> createState() => _DecodetailsState();
}

class _DecodetailsState extends State<Decodetails> {
  double avgRating = 0.0;
  bool isLoadingRatings = true;

  @override
  void initState() {
    super.initState();
    fetchDecorationRatings();
  }

  Future<void> fetchDecorationRatings() async {
    try {
      final response = await Supabase.instance.client
          .from('tbl_review')
          .select('review_rating')
          .eq('decorator_id', widget.decoration['decorator_id']);
      
      List<int> ratings = response.map<int>((row) => row['review_rating'] ?? 0).toList();
      setState(() {
        avgRating = ratings.isEmpty
            ? 0
            : ratings.reduce((a, b) => a + b) / ratings.length;
        isLoadingRatings = false;
      });
      print('Decoration Ratings: $avgRating'); // Debug log
    } catch (e) {
      print('Error fetching ratings: $e');
      setState(() {
        avgRating = 0;
        isLoadingRatings = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching ratings: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.decoration['decoration_title'] ?? "Decoration Details",
          style: GoogleFonts.cormorantGaramond(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 204, 209, 208),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.decoration['decoration_image'] ?? 'https://via.placeholder.com/300',
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.broken_image, size: 100));
                },
              ),
            ),
            const SizedBox(height: 20),

            Text(
              widget.decoration['decoration_title'] ?? "No Name",
              style: GoogleFonts.cormorantGaramond(fontSize: 26),
            ),
            const SizedBox(height: 10),

            Text(
              "Description:",
              style: GoogleFonts.cormorantGaramond(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.decoration['decoration_description'] ?? 'No description available',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            Text(
              "Price: \$${widget.decoration['decoration_budget'] ?? '0.00'}",
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 20),

            // Rating Display
            Row(
              children: [
                Text(
                  "Rating: ",
                  style: GoogleFonts.cormorantGaramond(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                isLoadingRatings
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ...List.generate(
                            5,
                            (star) => Icon(
                              star < avgRating.round() ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            avgRating > 0 ? avgRating.toStringAsFixed(1) : "No ratings",
                            style: const TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ],
                      ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              "Decorator Details:",
              style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Name: ${widget.decoration['tbl_decorators']?['dec_name'] ?? 'Unknown'}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Email: ${widget.decoration['tbl_decorators']?['dec_email'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SendRequest(id: widget.decoration['id']),
                  ),
                );
              },
              child: const Text('Send Request'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MoreDecorations(id: widget.decoration['decorator_id']),
                  ),
                );
              },
              child: const Text('View More'),
            ),
          ],
        ),
      ),
    );
  }
}