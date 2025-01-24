import 'package:flutter/foundation.dart';
import '../../../data/models/rental.dart';
import '../../../data/repositories/rental_repository.dart';
import '../../../core/services/storage_service.dart';
import 'package:flutter/material.dart';

enum PaymentMethod {
  card,
  toss,
  naver,
  kakao,
}

class PaymentViewModel with ChangeNotifier {
  final RentalRepository _rentalRepository;
  final StorageService _storageService;
  final Rental rental;
  PaymentMethod? _selectedMethod;
  bool _isLoading = false;
  String? _error;
  bool _isComplete = false;

  PaymentViewModel({
    required this.rental,
    RentalRepository? rentalRepository,
    StorageService? storageService,
  })  : _rentalRepository = rentalRepository ?? RentalRepository.instance,
        _storageService = storageService ?? StorageService.instance;

  PaymentMethod? get selectedMethod => _selectedMethod;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isComplete => _isComplete;

  Future<void> requestPayment() async {
    if (_selectedMethod == null) {
      _error = '결제 수단을 선택해주세요';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 결제 시뮬레이션을 위한 딜레이
      await Future.delayed(const Duration(seconds: 2));

      // 결제 성공 처리
      await _rentalRepository.create(rental);
      await _storageService.clearSelections();
      _isComplete = true;
    } catch (e) {
      _error = '결제 처리 중 오류가 발생했습니다';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectPaymentMethod(PaymentMethod method) {
    _selectedMethod = method;
    notifyListeners();
  }

  String getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card:
        return '카드 결제';
      case PaymentMethod.toss:
        return '토스 결제';
      case PaymentMethod.naver:
        return '네이버페이';
      case PaymentMethod.kakao:
        return '카카오페이';
    }
  }
}
