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

class _DecodetailsState extends State<Decodetails> with SingleTickerProviderStateMixin {
  double avgRating = 0.0;
  bool isLoadingRatings = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    fetchDecorationRatings();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      print('Decoration Ratings: $avgRating');
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.decoration['decoration_title'] ?? "Decoration Details",
          style: GoogleFonts.lora(
            fontWeight: FontWeight.w600,
            color: Color(0xFF3E2723),
          ),
        ),
        iconTheme: IconThemeData(color: Color(0xFF8D6E63)),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.decoration['decoration_image'] ?? 'https://via.placeholder.com/300',
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      color: Colors.grey.shade200,
                      child: Icon(Icons.broken_image, size: 100, color: Colors.grey.shade400),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.decoration['decoration_title'] ?? "No Name",
                style: GoogleFonts.lora(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Description:",
                style: GoogleFonts.lora(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.decoration['decoration_description'] ?? 'No description available',
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Price: \$${widget.decoration['decoration_budget'] ?? '0.00'}",
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF81C784),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    "Rating: ",
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  isLoadingRatings
                      ? CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF8D6E63))
                      : Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            ...List.generate(
                              5,
                              (star) => Icon(
                                star < avgRating.round() ? Icons.star : Icons.star_border,
                                color: Color(0xFFFFCC80),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              avgRating > 0 ? avgRating.toStringAsFixed(1) : "No ratings",
                              style: GoogleFonts.openSans(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Decorator Details:",
                style: GoogleFonts.lora(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Name: ${widget.decoration['tbl_decorators']?['dec_name'] ?? 'Unknown'}",
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                "Email: ${widget.decoration['tbl_decorators']?['dec_email'] ?? 'N/A'}",
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SendRequest(id: widget.decoration['id']),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6D4C41),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      'Send Request',
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8D6E63),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      'View More',
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}