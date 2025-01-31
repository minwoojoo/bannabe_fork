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
import '../../../core/services/storage_service.dart';

class QRScanView extends StatelessWidget {
  final int rentalDuration;
  final bool isReturn;
  final Rental? rental;

  const QRScanView({
    super.key,
    required this.rentalDuration,
    required this.isReturn,
    this.rental,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QRScanViewModel(
        rentalDuration: rentalDuration,
        isReturn: isReturn,
      )..addListener(() {
          final viewModel = context.read<QRScanViewModel>();
          if (viewModel.rental != null) {
            if (isReturn) {
              // 반납 완료 시 반납 완료 상태로 돌아가기
              Navigator.of(context).pop(true);
            } else {
              // 대여 시 결제 화면으로 이동
              Navigator.of(context).pushReplacementNamed(
                Routes.payment,
                arguments: viewModel.rental,
              );
            }
          }
        }),
      child: const _QRScanView(),
    );
  }
}

class _QRScanView extends StatelessWidget {
  const _QRScanView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<QRScanViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.isReturn ? 'QR 스캔하여 반납하기' : 'QR 스캔하여 대여하기'),
        actions: [
          // 스킵 버튼 추가
          TextButton(
            onPressed: () async {
              // 선택된 정보 확인
              final storageService = StorageService.instance;
              final selectedStationId =
                  await storageService.getString('selected_station_id');
              final selectedAccessoryId =
                  await storageService.getString('selected_accessory_id');

              print('=== 선택된 정보 ===');
              print('선택된 스테이션 ID: $selectedStationId');
              print('선택된 액세서리 ID: $selectedAccessoryId');
              print('==================');

              if (context.mounted) {
                if (viewModel.isReturn) {
                  Navigator.of(context).pop(true);
                } else {
                  Navigator.of(context).pushReplacementNamed(Routes.payment);
                }
              }
            },
            child: const Text(
              '[DEV] 스킵',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (Provider.of<QRScanViewModel>(context).hasCameraPermission) ...[
            QRView(
              key: GlobalKey(debugLabel: 'QR'),
              onQRViewCreated: viewModel.onQRViewCreated,
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
                  Provider.of<QRScanViewModel>(context).isReturn
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
          if (Provider.of<QRScanViewModel>(context).error != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            Provider.of<QRScanViewModel>(context).error!,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              Provider.of<QRScanViewModel>(context,
                                      listen: false)
                                  .clearError();
                            },
                            child: const Text('다시 스캔하기'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('돌아가기'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (Provider.of<QRScanViewModel>(context).isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
