import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:lottie/lottie.dart';
import 'package:image_geneartion_using_api/resources/generateImage.dart';

import 'package:image_geneartion_using_api/resources/logic.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Art Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const GenerateImage(),
    );
  }
}

class GenerateImage extends StatefulWidget {
  const GenerateImage({super.key});

  @override
  State<GenerateImage> createState() => _GenerateImageState();
}

class _GenerateImageState extends State<GenerateImage> {
  final TextEditingController promptController = TextEditingController();
  final TextEditingController negativePromptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImageGenerationController imageGenerationController = Get.put(ImageGenerationController());

  int totalLengthPrompt = 200;
  int presentLengthPrompt = 0;
  int totalLengthNPrompt = 150;
  int presentLengthNPrompt = 0;
  int selectedArtStyle = 0;
  int selectedAspectRatio = 0;
  bool isGenerating = false;
  Uint8List? generatedImageUrl;
  bool showGeneratedBtn = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent / 2) {
      if (!showGeneratedBtn) {
        setState(() => showGeneratedBtn = true);
      }
    } else {
      if (showGeneratedBtn) {
        setState(() => showGeneratedBtn = false);
      }
    }
  }

  Future<void> generateAiImage() async {
    if (promptController.text.isEmpty || negativePromptController.text.isEmpty) {
      debugPrint("Please enter both prompts");
      return;
    }

    setState(() => isGenerating = true);

    try {
      int styleId = Content.artStylesId[selectedArtStyle];
      String aspectRatio = Content.aspectRatios[selectedAspectRatio];
      generatedImageUrl = await imageGenerationController.generateImage(
        promptController.text,
        negativePromptController.text,
        aspectRatio,
        styleId,
        context,
      );
    } catch (e) {
      debugPrint("Error: generateAiImage() > $e");
    } finally {
      setState(() => isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWeb = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: isWeb ? size.width * 0.1 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // App Title
                  Text(
                    "AI Art Studio",
                    style: TextStyle(
                      fontSize: isWeb ? 40 : 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Create stunning AI-generated art with Midjourney",
                    style: TextStyle(
                      fontSize: isWeb ? 18 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Prompt Fields
                  _buildPromptField(
                    hintText: "Enter prompt to generate image",
                    controller: promptController,
                    totalLength: totalLengthPrompt,
                    presentLength: presentLengthPrompt,

                    onChanged: (val) => setState(() => presentLengthPrompt = val.length),
                    isWeb: isWeb,
                    decoration: InputDecoration(
                      hintText: "Enter prompt to generate image",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildPromptField(
                    hintText: "Enter negative prompt",
                    controller: negativePromptController,
                    totalLength: totalLengthNPrompt,
                    presentLength: presentLengthNPrompt,
                    onChanged: (val) => setState(() => presentLengthNPrompt = val.length),
                    isWeb: isWeb,
                    decoration: InputDecoration(
                      hintText: "Enter negative prompt",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 30),
                  // Art Styles Section
                  _buildSectionHeader(
                    title: "Art Styles",
                    subtitle: "Select your favorite art style for image generation",
                    isWeb: isWeb,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: isWeb ? 220 : 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: Content.artStylesText.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        return _buildArtStyleCard(index, isWeb);
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Aspect Ratio Section
                  _buildSectionHeader(
                    title: "Aspect Ratio",
                    subtitle: "Select the aspect ratio for your image",
                    isWeb: isWeb,
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWeb ? 4 : 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: isWeb ? 3 : 2.5,
                    ),
                    itemCount: Content.aspectRatios.length,
                    itemBuilder: (context, index) {
                      return _buildAspectRatioButton(index);
                    },
                  ),
                  const SizedBox(height: 30),
                  // Generated Image Section
                  DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(12),
                    dashPattern: const [6, 4],
                    color: Colors.grey.withOpacity(0.5),
                    child: Container(
                      width: double.infinity,
                      height: isWeb ? 400 : 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[100],
                      ),
                      child: isGenerating
                          ? Center(
                        child: Lottie.asset(
                          "assets/animations/image_construction.json",
                          fit: BoxFit.cover,
                        ),
                      )
                          : generatedImageUrl != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          generatedImageUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Center(
                        child: Text(
                          "Generated Image will appear here",
                          style: TextStyle(
                            fontSize: isWeb ? 18 : 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            // Generate Button
            if (showGeneratedBtn)
              Positioned(
                bottom: 20,
                left: isWeb ? size.width * 0.1 : 16,
                right: isWeb ? size.width * 0.1 : 16,
                child: AnimatedOpacity(
                  opacity: showGeneratedBtn ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: ElevatedButton(
                    onPressed: generateAiImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: Colors.deepPurpleAccent.withOpacity(0.3),
                    ),
                    child: isGenerating
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      "Generate Image",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptField({
    required String hintText,
    required TextEditingController controller,
    required int totalLength,
    required int presentLength,
    required Function(String) onChanged,
    required bool isWeb, required InputDecoration decoration,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            maxLines: isWeb ? 5 : 3,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
            ),
            onChanged: onChanged,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.deepPurpleAccent),
                onPressed: () {
                  controller.clear();
                  onChanged("");
                },
              ),
              Text(
                "$presentLength/$totalLength",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required String subtitle, required bool isWeb}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isWeb ? 28 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: isWeb ? 16 : 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildArtStyleCard(int index, bool isWeb) {
    return GestureDetector(
      onTap: () => setState(() => selectedArtStyle = index),
      child: Container(
        width: isWeb ? 180 : 140,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedArtStyle == index ? Colors.deepPurpleAccent : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                Content.artStylesImages[index],
                fit: BoxFit.cover,
                height: isWeb ? 140 : 100,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Content.artStylesText[index],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAspectRatioButton(int index) {
    return GestureDetector(
      onTap: () => setState(() => selectedAspectRatio = index),
      child: Container(
        decoration: BoxDecoration(
          color: selectedAspectRatio == index ? Colors.deepPurpleAccent : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selectedAspectRatio == index ? Colors.deepPurpleAccent : Colors.grey[300]!,
          ),
        ),
        child: Center(
          child: Text(
            Content.aspectRatios[index],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: selectedAspectRatio == index ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}