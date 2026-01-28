import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/blog_card.dart';

class PortalScreen extends StatefulWidget {
  const PortalScreen({super.key});

  @override
  State<PortalScreen> createState() => _PortalScreenState();
}

class _PortalScreenState extends State<PortalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> _newsItems = [
    {
      "title": "Government Announces New Subsidy for Rice Farmers",
      "summary":
          "The Ministry of Agriculture has unveiled a new subsidy plan to support rice farmers during the monsoon season...",
      "date": "2 hours ago",
      "image":
          "https://images.unsplash.com/photo-1530507629858-e4977d30e9e0?q=80&w=2038&auto=format&fit=crop",
      "tag": "News",
    },
    {
      "title": "Potato Prices Surge Due to Supply Chain Issues",
      "summary":
          "Market analysis shows a 15% increase in potato prices across major cities as transport strikes continue...",
      "date": "1 day ago",
      "image":
          "https://images.unsplash.com/photo-1596450514735-37330c6cb4f2?q=80&w=2070&auto=format&fit=crop",
      "tag": "Market",
    },
    {
      "title": "New Pest Alert: Tomato Leaf Miner Outbreak",
      "summary":
          "Farmers in the southern plains warn of a rapid spread of Tuta absoluta. Experts advise immediate action...",
      "date": "2 days ago",
      "image":
          "https://images.unsplash.com/photo-1591586562478-f73df016c641?q=80&w=2070&auto=format&fit=crop",
      "tag": "Alert",
    },
  ];

  final List<Map<String, String>> _blogItems = [
    {
      "title": "Sustainable Farming: Determine Fertilizer Needs",
      "summary":
          "Using too much fertilizer harms the soil. Learn how to calculate the exact NPK requirements for your crop...",
      "date": "Jan 28, 2026",
      "image":
          "https://images.unsplash.com/photo-1625246333195-09d9b630dc20?q=80&w=2070&auto=format&fit=crop",
      "tag": "Guide",
    },
    {
      "title": "The Future of Smart Agriculture in Nepal",
      "summary":
          "From drones to AI-based disease detection, see how technology is transforming traditional farming methods...",
      "date": "Jan 25, 2026",
      "image":
          "https://images.unsplash.com/photo-1530836369250-ef72a3f5cda8?q=80&w=2070&auto=format&fit=crop",
      "tag": "Tech",
    },
    {
      "title": "Organic Pest Control Methods for Tomatoes",
      "summary":
          "Stop using harsh chemicals. Here are 5 natural remedies to keep your tomato plants healthy and bug-free...",
      "date": "Jan 20, 2026",
      "image":
          "https://images.unsplash.com/photo-1592841200221-a6898f307baa?q=80&w=1974&auto=format&fit=crop",
      "tag": "Organic",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Knowledge Portal",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: "News & Updates"),
            Tab(text: "Educational Blogs"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // News Tab
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _newsItems.length,
            itemBuilder: (context, index) {
              final item = _newsItems[index];
              return BlogCard(
                title: item['title']!,
                summary: item['summary']!,
                date: item['date']!,
                imageUrl: item['image']!,
                tag: item['tag']!,
                onTap: () {
                  // In real app, navigate to details
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Reading: ${item['title']}")),
                  );
                },
              );
            },
          ),

          // Blogs Tab
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _blogItems.length,
            itemBuilder: (context, index) {
              final item = _blogItems[index];
              return BlogCard(
                title: item['title']!,
                summary: item['summary']!,
                date: item['date']!,
                imageUrl: item['image']!,
                tag: item['tag']!,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Reading: ${item['title']}")),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
