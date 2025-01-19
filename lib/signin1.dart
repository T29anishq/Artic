import 'package:flutter/material.dart';
import 'signin2.dart'; // Import the next page

class ArtFormSelectionPage extends StatefulWidget {
  final String username;
  final String email;
  final String dateOfBirth;

  const ArtFormSelectionPage({
    Key? key,
    required this.username,
    required this.email,
    required this.dateOfBirth,
  }) : super(key: key);

  @override
  _ArtFormSelectionPageState createState() => _ArtFormSelectionPageState();
}

class _ArtFormSelectionPageState extends State<ArtFormSelectionPage> {
  final TextEditingController artworkController = TextEditingController();
  final TextEditingController genreController = TextEditingController();

  List<String> artworks = [];
  List<String> genres = [];

  List<String> artworkSuggestions = [
    'Painting',
    'Sculpture',
    'Photography',
    'Digital Art',
    'Drawing',
  ];

  List<String> genreSuggestions = [
    'Fantasy',
    'Sci-Fi',
    'Romance',
    'Mystery',
    'Horror',
  ];

  List<String> filteredArtworkSuggestions = [];
  List<String> filteredGenreSuggestions = [];
  bool isArtworkDropdownVisible = false;
  bool isGenreDropdownVisible = false;

  @override
  void initState() {
    super.initState();
    artworkController.addListener(_filterArtworkSuggestions);
    genreController.addListener(_filterGenreSuggestions);
  }

  void _filterArtworkSuggestions() {
    final query = artworkController.text.toLowerCase();
    setState(() {
      filteredArtworkSuggestions = artworkSuggestions
          .where((artwork) => artwork.toLowerCase().contains(query))
          .toList();
      isArtworkDropdownVisible = filteredArtworkSuggestions.isNotEmpty;
      isGenreDropdownVisible = false;
    });
  }

  void _filterGenreSuggestions() {
    final query = genreController.text.toLowerCase();
    setState(() {
      filteredGenreSuggestions = genreSuggestions
          .where((genre) => genre.toLowerCase().contains(query))
          .toList();
      isGenreDropdownVisible = filteredGenreSuggestions.isNotEmpty;
      isArtworkDropdownVisible = false;
    });
  }

  void _addArtwork(String artwork) {
    if (!artworks.contains(artwork)) {
      setState(() {
        artworks.add(artwork);
        artworkController.clear();
        isArtworkDropdownVisible = false;
      });
    }
  }

  void _addGenre(String genre) {
    if (!genres.contains(genre)) {
      setState(() {
        genres.add(genre);
        genreController.clear();
        isGenreDropdownVisible = false;
      });
    }
  }

  void _removeArtwork(String artwork) {
    setState(() {
      artworks.remove(artwork);
    });
  }

  void _removeGenre(String genre) {
    setState(() {
      genres.remove(genre);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isArtworkDropdownVisible = false;
          isGenreDropdownVisible = false;
        });
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E), // Dark background color
        appBar: AppBar(
          backgroundColor: const Color(0xFF162447), // Dark blue
          title: const Text('Art Form Selection'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            // Make the page scrollable
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment
                    .stretch, // Stretch elements to prevent overflow
                children: [
                  const Text(
                    'Select Your Interested Art Forms and Genres',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: artworkController,
                    decoration: InputDecoration(
                      labelText: 'Type Artwork',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF162447),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onTap: () {
                      setState(() {
                        isArtworkDropdownVisible = true;
                        isGenreDropdownVisible = false;
                      });
                    },
                  ),
                  if (isArtworkDropdownVisible)
                    Column(
                      children: filteredArtworkSuggestions.map((suggestion) {
                        return ListTile(
                          title: Text(suggestion,
                              style: const TextStyle(color: Colors.white)),
                          onTap: () => _addArtwork(suggestion),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: genreController,
                    decoration: InputDecoration(
                      labelText: 'Type Genre',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF162447),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onTap: () {
                      setState(() {
                        isGenreDropdownVisible = true;
                        isArtworkDropdownVisible = false;
                      });
                    },
                  ),
                  if (isGenreDropdownVisible)
                    Column(
                      children: filteredGenreSuggestions.map((suggestion) {
                        return ListTile(
                          title: Text(suggestion,
                              style: const TextStyle(color: Colors.white)),
                          onTap: () => _addGenre(suggestion),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    'Selected Artworks:',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Wrap(
                    spacing: 10.0,
                    children: artworks.map((artwork) {
                      return ActionChip(
                        label: Text(artwork,
                            style: const TextStyle(color: Colors.white)),
                        backgroundColor: Color(0xff8568ff),
                        onPressed: () => _removeArtwork(artwork),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Selected Genres:',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Wrap(
                    spacing: 10.0,
                    children: genres.map((genre) {
                      return ActionChip(
                        label: Text(genre,
                            style: const TextStyle(color: Colors.white)),
                        backgroundColor: Color(0xff8568ff),
                        onPressed: () => _removeGenre(genre),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignIn2Page(
                            username: widget.username,
                            email: widget.email,
                            dateOfBirth: widget.dateOfBirth,
                            selectedArtworks: artworks,
                            selectedGenres: genres,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Continue',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff8a07c1),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      textStyle:
                          const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
