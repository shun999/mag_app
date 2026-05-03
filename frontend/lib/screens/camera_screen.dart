import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'result_screen.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  int _cameraIndex = 0;
  bool _showFlash = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (widget.cameras.isEmpty) return;
    // 背面カメラを優先
    _cameraIndex = widget.cameras.indexWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
    );
    if (_cameraIndex < 0) _cameraIndex = 0;
    await _startCamera(_cameraIndex);
  }

  Future<void> _startCamera(int index) async {
    _controller?.dispose();
    final controller = CameraController(
      widget.cameras[index],
      ResolutionPreset.high,
      enableAudio: false,
    );
    await controller.initialize();
    if (!mounted) return;
    setState(() {
      _controller = controller;
      _cameraIndex = index;
    });
  }

  Future<void> _flipCamera() async {
    if (widget.cameras.length < 2) return;
    final next = (_cameraIndex + 1) % widget.cameras.length;
    await _startCamera(next);
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isTakingPicture) return;

    // フラッシュエフェクト
    setState(() => _showFlash = true);
    await Future.delayed(const Duration(milliseconds: 120));
    if (mounted) setState(() => _showFlash = false);

    final xFile = await controller.takePicture();
    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultScreen(imageFile: File(xFile.path)),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cameraBg,
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'インゴット検査',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    child: const Icon(
                      Icons.light_mode_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),

            // ビューファインダー
            Expanded(
              child: Stack(
                children: [
                  // カメラプレビュー
                  Container(
                    color: AppColors.viewfinderBg,
                    child: _controller != null &&
                            _controller!.value.isInitialized
                        ? Center(child: CameraPreview(_controller!))
                        : const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                  ),

                  // コーナーマーカー
                  _buildCornerMarkers(),

                  // ヒントテキスト
                  if (_controller == null || !_controller!.value.isInitialized)
                    Center(
                      child: Text(
                        'インゴットをフレームに合わせてください',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 12,
                        ),
                      ),
                    ),

                  // フラッシュエフェクト
                  if (_showFlash)
                    Container(color: Colors.white),
                ],
              ),
            ),

            // カメラコントロール
            Container(
              color: AppColors.cameraBg,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // サムネイルプレースホルダ
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 0.5,
                      ),
                    ),
                  ),

                  // シャッターボタン
                  GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // カメラ切替ボタン
                  GestureDetector(
                    onTap: _flipCamera,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 0.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.cameraswitch_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerMarkers() {
    const size = 28.0;
    const margin = 20.0;
    const color = AppColors.primary;
    const width = 2.5;

    return Stack(
      children: [
        // 左上
        Positioned(
          top: margin,
          left: margin,
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: color, width: width),
                left: BorderSide(color: color, width: width),
              ),
            ),
          ),
        ),
        // 右上
        Positioned(
          top: margin,
          right: margin,
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: color, width: width),
                right: BorderSide(color: color, width: width),
              ),
            ),
          ),
        ),
        // 左下
        Positioned(
          bottom: margin,
          left: margin,
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: color, width: width),
                left: BorderSide(color: color, width: width),
              ),
            ),
          ),
        ),
        // 右下
        Positioned(
          bottom: margin,
          right: margin,
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: color, width: width),
                right: BorderSide(color: color, width: width),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
