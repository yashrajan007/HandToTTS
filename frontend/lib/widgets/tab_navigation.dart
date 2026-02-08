import 'package:flutter/material.dart';
import 'screens/ocr_screen.dart';
import 'screens/ocr_with_prompt_screen.dart';
import 'screens/text_to_audio_screen.dart';

class TabNavigationWidget extends StatelessWidget {
  final TabController tabController;

  const TabNavigationWidget({Key? key, required this.tabController})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: tabController,
          tabs: const [
            Tab(icon: Icon(Icons.text_fields), text: 'Extract Text'),
            Tab(icon: Icon(Icons.edit), text: 'Custom Prompt'),
            Tab(icon: Icon(Icons.volume_up), text: 'Text to Audio'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: const [
              OcrScreen(),
              OcrWithPromptScreen(),
              TextToAudioScreen(),
            ],
          ),
        ),
      ],
    );
  }
}
