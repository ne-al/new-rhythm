import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rhythm/app/screens/pages/view/playlist/presentation/playlist_view.dart';

Widget playlistCardWidget(
    List playlistData, String title, BoxConstraints constraints) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Gap(16),
      Padding(
        padding: const EdgeInsets.only(left: 26),
        child: Text(
          title,
          style: GoogleFonts.oswald(
            fontSize: 28,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      const Gap(16),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Scrollbar(
          child: SizedBox(
            height: constraints.maxHeight * 0.26,
            child: CustomScrollView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              slivers: [
                SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                  ),
                  itemCount: playlistData.length,
                  itemBuilder: (context, index) {
                    Map data = playlistData[index];
                    String thumbnailUrl = data['image']
                        .toString()
                        .replaceAll('150x150', '500x500');

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaylistView(
                              id: data['id'],
                              type: data['type'],
                              thumbnailUrl: thumbnailUrl,
                              title: data['title'],
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Flexible(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: thumbnailUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const Gap(8),
                          SizedBox(
                            width: constraints.maxWidth * 0.4,
                            child: Column(
                              children: [
                                Text(
                                  data['title'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  data['type'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
