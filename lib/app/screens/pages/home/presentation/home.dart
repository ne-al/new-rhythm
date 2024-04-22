import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rhythm/app/components/textfield/search_textfield.dart';
import 'package:rhythm/app/screens/pages/home/data/services/home_service.dart';
import 'package:rhythm/app/screens/pages/home/widgets/playlist_card_widget.dart';
import 'package:rhythm/app/screens/pages/search/presentation/search.dart';
import 'package:rhythm/core/utils/error/error_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  bool isLoading = false;

  Map<dynamic, dynamic> homePageData = {};

  List<dynamic> newTrending = [];
  List<dynamic> charts = [];
  List<dynamic> newAlbums = [];
  List<dynamic> tagMixes = [];
  List<dynamic> topPlaylists = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      isLoading = true;
    });
    homePageData = await HomeService().getHomePage();

    newTrending = homePageData['new_trending'] as List<dynamic>;
    charts = homePageData['charts'] as List<dynamic>;
    newAlbums = homePageData['new_albums'] as List<dynamic>;
    tagMixes = homePageData['tag_mixes'] as List<dynamic>;
    topPlaylists = homePageData['top_playlists'] as List<dynamic>;

    setState(() {
      isLoading = false;
    });
  }

  /*
    "new_trending",
    "charts",
    "new_albums",
    "tag_mixes",
    "top_playlists",
    "radio",
    "city_mod",
    "artist_recos",
   */

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
                  forceMaterialTransparency: false,
                  expandedHeight: constraints.minHeight * 0.15,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RHYTHM',
                          style: GoogleFonts.oswald(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.6,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              iconSize: 16,
                              onPressed: () {
                                ErrorUtils().featureNotAvailable(context);
                              },
                              icon: const Icon(Icons.settings_rounded),
                            ),
                            IconButton(
                              iconSize: 16,
                              onPressed: () {
                                ErrorUtils().featureNotAvailable(context);
                              },
                              icon: const Icon(Icons.library_music_rounded),
                            ),
                          ],
                        ),
                      ],
                    ),
                    titlePadding: const EdgeInsets.only(
                      bottom: 80,
                      left: 20,
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(70),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: SizedBox(
                        width: constraints.maxWidth * 0.95,
                        child: SearchTextField(
                          controller: _searchController,
                          onSubmitted: (p0) {
                            if (_searchController.text.trim().isEmpty) {
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchPage(
                                  query: _searchController.text.trim(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: !isLoading
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //! New Trending
                            playlistCardWidget(
                                newTrending, 'New Trending', constraints),

                            //! New Albums
                            playlistCardWidget(
                                newAlbums, 'New Albums', constraints),

                            //! Top Playlists
                            playlistCardWidget(
                                topPlaylists, 'Top Playlists', constraints),

                            //! Top Charts
                            playlistCardWidget(
                                charts, 'Top Charts', constraints),
                          ],
                        )
                      : const Center(
                          child: LinearProgressIndicator(),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
