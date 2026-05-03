import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'screens/camera_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

class IngotInspectorApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const IngotInspectorApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'インゴット検査',
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      home: MainShell(cameras: cameras),
    );
  }
}

class MainShell extends StatefulWidget {
  final List<CameraDescription> cameras;
  const MainShell({super.key, required this.cameras});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      CameraScreen(cameras: widget.cameras),
      const HistoryScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // カメラ画面はダークUIなので、BottomNavigationBar のスタイルを切り替える
    final isCameraTab = _currentIndex == 0;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: isCameraTab ? AppColors.cameraBg : null,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          selectedItemColor: AppColors.primary,
          unselectedItemColor:
              isCameraTab ? Colors.white38 : Colors.grey,
          backgroundColor:
              isCameraTab ? AppColors.cameraBg : null,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_outlined),
              activeIcon: Icon(Icons.camera_alt),
              label: 'カメラ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: '履歴',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: '設定',
            ),
          ],
        ),
      ),
    );
  }
}
