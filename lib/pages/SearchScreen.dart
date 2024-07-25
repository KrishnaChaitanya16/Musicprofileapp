import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:muiscprofileapp/pages/ProfileScreen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<String> imageUrls = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchResults = false;
  List<DocumentSnapshot> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchImages() async {
    try {
      final FirebaseStorage storage = FirebaseStorage.instance;
      final ListResult result = await storage.ref('posts').listAll(); // Changed to 'posts'

      final List<String> urls = [];
      for (final Reference ref in result.items) {
        final String url = await ref.getDownloadURL();
        urls.add(url);
      }

      setState(() {
        imageUrls = urls;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching images: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<String> _getRepeatingImages() {
    if (imageUrls.isEmpty) {
      return [];
    }
    final List<String> repeatingUrls = [];
    for (int i = 0; i < 30; i++) { // Use 30 images
      repeatingUrls.add(imageUrls[i % imageUrls.length]);
    }
    return repeatingUrls;
  }

  void _onSearchTextChanged(String text) async {
    if (text.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final QuerySnapshot snapshot = await firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: text)
          .where('username', isLessThanOrEqualTo: text + '\uf8ff')
          .get();

      setState(() {
        _searchResults = snapshot.docs;
        _showSearchResults = true;
      });
    } catch (e) {
      print('Error fetching users: $e');
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
    }
  }

  void _onClearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _showSearchResults = false;
    });
  }

  void _showImageDialog(String imageUrl, String username) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,

          child: Container(
            padding: EdgeInsets.all(15),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 1, // Use 90% of the screen width
              maxHeight: MediaQuery.of(context).size.height * 0.7, // Use 70% of the screen height
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity, // Ensure the image covers the dialog width
                  height: 300, // Increased height for the image
                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.white),
                ),
                SizedBox(height: 12),
                Text(
                  username,
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_up, color: Colors.white),
                      onPressed: () {
                        // Handle like action
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.share, color: Colors.white),
                      onPressed: () {
                        // Handle share action
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.comment, color: Colors.white),
                      onPressed: () {
                        // Handle comment action
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final List<String> displayedImages = _getRepeatingImages();

    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1f0d1d),
                  Color(0xFF140f13),
                ],
                stops: [0.01, 0.1],
              ),
            ),
          ),
          // Search container
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Color(0xFFc584b3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Color(0xFF13001a)),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(color: Color(0xFF13001a)),
                            decoration: InputDecoration(
                              hintText: 'Songs, New Links, Posts, Circles & More..',
                              hintStyle: TextStyle(color: Color(0xFF13001a).withOpacity(0.6)),
                              border: InputBorder.none,
                            ),
                            onChanged: _onSearchTextChanged,
                          ),
                        ),
                        if (_showSearchResults)
                          IconButton(
                            icon: Icon(Icons.clear, color: Color(0xFF13001a)),
                            onPressed: _onClearSearch,
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Image.asset('lib/icons/filter.png', height: 30, color: Colors.white),
                ),
              ],
            ),
          ),
          // Search Results
          if (_showSearchResults)
            Positioned(
              top: 120,
              left: 16,
              right: 16,
              bottom: 0,
              child: ListView(
                children: _searchResults.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final username = data['username'] ?? 'No username';
                  final profileImageUrl = data['profileImageUrl'] ?? '';
                  final linksCount = data['linksCount'] ?? 0;

                  return ListTile(
                    leading: profileImageUrl.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: profileImageUrl,
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    )
                        : Icon(Icons.account_circle, size: 50, color: Colors.white),
                    title: Text(
                      username,
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '$linksCount links',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                    tileColor: Color(0xFF2a0d1d),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(isOwnProfile: false), // For another user's profile
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            )
          else
          // Staggered Grid Items
            Positioned(
              top: 120,
              left: 16,
              right: 16,
              bottom: 0,
              child: SingleChildScrollView(
                child: StaggeredGrid.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: List.generate(displayedImages.length, (index) {
                    int crossAxisCellCount;
                    int mainAxisCellCount;

                    if (index == 0 || index == 5 || index == 10 || index == 15 || index == 20 || index == 25) {
                      crossAxisCellCount = 2;
                      mainAxisCellCount = 1;
                    } else if (index == 1 || index == 6 || index == 11 || index == 16 || index == 21 || index == 26) {
                      crossAxisCellCount = 1;
                      mainAxisCellCount = 2;
                    } else {
                      crossAxisCellCount = 1;
                      mainAxisCellCount = 1;
                    }

                    return StaggeredGridTile.count(
                      crossAxisCellCount: crossAxisCellCount,
                      mainAxisCellCount: mainAxisCellCount,
                      child: GestureDetector(
                        onTap: () => _showImageDialog(displayedImages[index], 'Sample Username'), // Use a sample username or fetch it from Firestore
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: displayedImages[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
