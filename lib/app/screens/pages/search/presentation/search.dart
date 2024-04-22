import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:jiosaavn_handler/jiosaavn_handler.dart';
import 'package:rhythm/app/components/listtile/song_listtile.dart';
import 'package:rhythm/app/components/textfield/search_textfield.dart';
import 'package:rhythm/core/handler/map_to_media_item.dart';

class SearchPage extends StatefulWidget {
  final String query;
  const SearchPage({
    super.key,
    required this.query,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Map _searchResult = {};
  final List<MediaItem> _songs = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.query;

    _searchSong();
  }

  Future<void> _searchSong() async {
    if (_searchController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    if (_songs.isNotEmpty) {
      _songs.clear();
    }

    _searchResult = await Api().fetchSongSearchResults(
      searchQuery: _searchController.text.trim(),
      count: 25,
    );

    for (var song in _searchResult['songs']) {
      _songs.add(MapToMediaItem.mapToMediaItem(song));
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Theme.of(context).colorScheme.background,
                  bottom: PreferredSize(
                    preferredSize: Size.zero,
                    child: SearchTextField(
                      controller: _searchController,
                      onSubmitted: (p0) {
                        _searchSong();
                      },
                    ),
                  ),
                ),
                !isLoading
                    ? SliverList.builder(
                        itemCount: _songs.length,
                        itemBuilder: (context, index) {
                          return SongListTile(
                            data: _songs[index],
                            constraints: constraints,
                          );
                        },
                      )
                    : const SliverToBoxAdapter(
                        child: LinearProgressIndicator(),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
