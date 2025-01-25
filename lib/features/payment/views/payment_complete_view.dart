import 'package:flutter/material.dart';
import '../../../data/models/rental.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/services/storage_service.dart';

class PaymentCompleteView extends StatelessWidget {
  final Rental rental;
  final _storageService = StorageService.instance;

  PaymentCompleteView({
    super.key,
    required this.rental,
  });

  Future<void> _clearRentalInfo() async {
    // 대여 관련 저장된 정보 모두 삭제
    await Future.wait([
      _storageService.remove('selected_accessory_id'),
      _storageService.remove('selected_station_id'),
      _storageService.remove('selected_accessory_name'),
      _storageService.remove('selected_station_name'),
      _storageService.remove('selected_rental_duration'),
      _storageService.remove('selected_price'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DefaultTextStyle.merge(
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
            height: 1.5,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  '결제가 완료되었습니다',
                  style: AppTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey[200]!,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('주문번호: ${rental.id}'),
                      const SizedBox(height: 8),
                      Text('결제금액: ${rental.totalPrice}원'),
                      const SizedBox(height: 8),
                      Text(
                        '대여시간: ${rental.formattedRentalTime}',
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    await _clearRentalInfo();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed(Routes.home);
                    }
                  },
                  child: const Text('홈으로 돌아가기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
