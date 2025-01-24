import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/models/rental.dart';
import '../viewmodels/qr_scan_viewmodel.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/app_colors.dart';
import '../../../app/routes.dart';
import '../../../core/widgets/loading_animation.dart';

class QRScanView extends StatelessWidget {
  final int rentalDuration;
  final bool isReturn;
  final Rental? rental;

  const QRScanView({
    super.key,
    required this.rentalDuration,
    this.isReturn = false,
    this.rental,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<QRScanViewModel>(
      create: (_) => QRScanViewModel(
        rentalDuration: rentalDuration,
        isReturn: isReturn,
        initialRental: rental,
      ),
      child: Builder(
        builder: (context) {
          final viewModel = Provider.of<QRScanViewModel>(context, listen: true);

          // QR 스캔 결과 처리
          if (!viewModel.isProcessing) {
            if (viewModel.isReturnComplete) {
              // 반납 완료 시 true 반환
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pop(true);
              });
            } else if (viewModel.rental != null && !viewModel.isReturn) {
              // 대여 시 결제 페이지로 이동
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacementNamed(
                  Routes.payment,
                  arguments: {
                    'accessory': {
                      'id': viewModel.rental!.accessoryId,
                      'name': viewModel.rental!.accessoryName,
                      'pricePerHour':
                          viewModel.rental!.totalPrice ~/ rentalDuration,
                    },
                    'station': {
                      'id': viewModel.rental!.stationId,
                      'name': viewModel.rental!.stationName,
                    },
                    'hours': rentalDuration,
                  },
                );
              });
            }
          }

          return const _QRScanContent();
        },
      ),
    );
  }
}

class _QRScanContent extends StatefulWidget {
  const _QRScanContent();

  @override
  State<_QRScanContent> createState() => _QRScanContentState();
}

class _QRScanContentState extends State<_QRScanContent> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR 스캔'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<QRScanViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isScanning) {
              return Stack(
                children: [
                  if (viewModel.hasCameraPermission) ...[
                    QRView(
                      key: qrKey,
                      onQRViewCreated: (QRViewController controller) {
                        this.controller = controller;
                        viewModel.onQRViewCreated(controller);
                      },
                      overlay: QrScannerOverlayShape(
                        borderColor: AppColors.primary,
                        borderRadius: 10,
                        borderLength: 30,
                        borderWidth: 10,
                        cutOutSize: 300,
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.only(bottom: 100),
                        child: Text(
                          viewModel.isReturn
                              ? '반납할 스테이션의 QR 코드를 스캔해주세요'
                              : '대여할 물품의 QR 코드를 스캔해주세요',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ] else ...[
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            color: AppColors.error,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '카메라 권한이 필요합니다',
                            style: AppTheme.bodyLarge.copyWith(
                              color: AppColors.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          TextButton(
                            onPressed: () => openAppSettings(),
                            child: const Text('설정으로 이동'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            }

            if (viewModel.isProcessing) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const HoneyLoadingAnimation(
                      isStationSelected: true,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      viewModel.isReturn
                          ? '반납을 처리하고 있습니다...'
                          : 'QR 코드를 처리하고 있습니다...',
                      style: AppTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (viewModel.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.error!,
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: viewModel.resumeScanning,
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
