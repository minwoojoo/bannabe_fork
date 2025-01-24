import 'package:flutter/foundation.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/models/rental.dart';
import '../../../data/repositories/rental_repository.dart';
import '../../../data/repositories/accessory_repository.dart';
import '../../../core/services/storage_service.dart';

class QRScanViewModel with ChangeNotifier {
  final AccessoryRepository _accessoryRepository;
  final StorageService _storageService;
  final int _rentalDuration;
  final bool isReturn;
  final Rental? initialRental;

  bool _isScanning = false;
  bool _isProcessing = false;
  bool _hasCameraPermission = false;
  String? _error;
  Rental? _rental;
  bool _isReturnComplete = false;
  int _rating = 0;
  QRViewController? _controller;

  QRScanViewModel({
    RentalRepository? rentalRepository,
    AccessoryRepository? accessoryRepository,
    StorageService? storageService,
    required int rentalDuration,
    this.isReturn = false,
    this.initialRental,
  })  : _accessoryRepository = accessoryRepository ?? AccessoryRepository(),
        _storageService = storageService ?? StorageService.instance,
        _rentalDuration = rentalDuration {
    _checkCameraPermission();
    _saveRentalDuration();
  }

  bool get isScanning => _isScanning;
  bool get isProcessing => _isProcessing;
  bool get hasCameraPermission => _hasCameraPermission;
  String? get error => _error;
  Rental? get rental => _rental;
  bool get isReturnComplete => _isReturnComplete;
  int get rating => _rating;

  Future<void> _saveRentalDuration() async {
    if (!isReturn) {
      await _storageService.setInt('rental_duration', _rentalDuration);
    }
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      _hasCameraPermission = true;
      _isScanning = true;
      notifyListeners();
      return;
    }

    final result = await Permission.camera.request();
    _hasCameraPermission = result.isGranted;
    _isScanning = result.isGranted;
    if (!result.isGranted) {
      _error = '카메라 권한이 필요합니다. 설정에서 권한을 허용해주세요.';
    }
    notifyListeners();
  }

  void setRating(int value) {
    _rating = value;
    notifyListeners();
  }

  void onQRViewCreated(QRViewController controller) {
    _controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null && !_isProcessing) {
        if (isReturn) {
          processReturnQRCode(scanData.code!);
        } else {
          processRentalQRCode(scanData.code!);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> processRentalQRCode(String qrCode) async {
    _isScanning = false;
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      // QR 코드에서 액세서리 ID와 스테이션 ID 추출
      final parts = qrCode.split('-');
      if (parts.length != 2) {
        throw Exception('잘못된 QR 코드입니다.');
      }

      final stationId = parts[0];
      final accessoryId = parts[1];

      // 액세서리 정보 조회와 정보 저장을 동시에 처리
      final Future<void> saveFuture = Future.wait([
        _storageService.setString('scanned_accessory_id', accessoryId),
        _storageService.setString('scanned_station_id', stationId),
      ]);

      final accessory = await _accessoryRepository.get(accessoryId);
      if (!accessory.isAvailable) {
        throw Exception('현재 대여할 수 없는 물품입니다.');
      }

      await saveFuture;

      _rental = Rental(
        id: 'rental-${DateTime.now().millisecondsSinceEpoch}',
        userId: 'test-user-id', // TODO: 실제 사용자 ID로 변경
        accessoryId: accessoryId,
        stationId: stationId,
        accessoryName: accessory.name,
        stationName: '강남역점', // TODO: 실제 스테이션 이름으로 변경
        totalPrice: _rentalDuration * accessory.pricePerHour,
        status: RentalStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> processReturnQRCode(String qrCode) async {
    if (initialRental == null) {
      _error = '반납할 대여 정보가 없습니다';
      notifyListeners();
      return;
    }

    _isScanning = false;
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      // QR 코드에서 스테이션 ID 추출
      final stationId = qrCode.split('-')[0];

      // 반납 처리
      final now = DateTime.now();
      _rental = Rental(
        id: initialRental!.id,
        userId: initialRental!.userId,
        accessoryId: initialRental!.accessoryId,
        stationId: stationId,
        accessoryName: initialRental!.accessoryName,
        stationName: initialRental!.stationName,
        totalPrice: initialRental!.totalPrice,
        status: RentalStatus.completed,
        createdAt: initialRental!.createdAt,
        updatedAt: now,
      );
      _isReturnComplete = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void resumeScanning() {
    _isScanning = true;
    _error = null;
    notifyListeners();
  }
}
