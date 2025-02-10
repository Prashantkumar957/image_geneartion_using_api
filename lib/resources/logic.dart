import 'package:flutter/material.dart';

class Content {
  // art style text list
  static List<String> artStylesText = [
    "Anime",
    "Realistic",
    "Portrait",
  ];

  static List<int> artStylesId = [
    21,
    29,
    26,
  ];

  // art style images
  static List<String> artStylesImages = [
    "assets/images/anime.jpg",
    "assets/images/realistic.jpeg",
    "assets/images/portrait.webp",
  ];

  // image aspect ratio values
  static List<String> aspectRatios = [
    "1:1",
    "3:2",
    "4:3",
    "3:4",
    "16:9",
    "9:16",
  ];

  static List drawerIconsList = [
    Icons.browser_updated_outlined,
    Icons.notifications,
    Icons.edit_document,
    Icons.help
  ];
  static List drawerTitlesList = [
    "Midjourney AI",
    "Notifications",
    "Manual",
    "Help"
  ];
}
