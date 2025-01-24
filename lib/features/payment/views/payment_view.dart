import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/rental.dart';
import '../../../app/routes.dart';

enum PaymentMethod {
  card,
  toss,
  naver,
  kakao,
}

class PaymentView extends StatefulWidget {
  const PaymentView({super.key});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  String? accessoryName;
  String? stationName;
  int? hours;
  int? totalPrice;
  PaymentMethod selectedMethod = PaymentMethod.card;
  bool agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _loadSavedInfo();
  }

  Future<void> _loadSavedInfo() async {
    final storage = StorageService.instance;
    final savedAccessoryName =
        await storage.getString('selected_accessory_name');
    final savedStationName = await storage.getString('selected_station_name');
    final savedHours = await storage.getInt('selected_rental_duration');
    final savedPrice = await storage.getInt('selected_price');

    if (mounted) {
      setState(() {
        accessoryName = savedAccessoryName;
        stationName = savedStationName;
        hours = savedHours;
        totalPrice = savedPrice;
      });
    }
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card:
        return '신용/체크카드';
      case PaymentMethod.toss:
        return '토스페이';
      case PaymentMethod.naver:
        return '네이버페이';
      case PaymentMethod.kakao:
        return '카카오페이';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('결제하기'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('대여 정보', style: AppTheme.titleMedium),
                              const SizedBox(height: 16),
                              Text('스테이션: ${stationName ?? ""}'),
                              const SizedBox(height: 8),
                              Text('상품: ${accessoryName ?? ""}'),
                              const SizedBox(height: 8),
                              Text('대여 시간: ${hours ?? 0}시간'),
                              const SizedBox(height: 8),
                              Text('결제 금액: ${totalPrice ?? 0}원'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('결제 수단', style: AppTheme.titleMedium),
                              const SizedBox(height: 16),
                              ...PaymentMethod.values.map((method) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Radio<PaymentMethod>(
                                      value: method,
                                      groupValue: selectedMethod,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedMethod = value!;
                                        });
                                      },
                                    ),
                                    title: Text(_getPaymentMethodName(method)),
                                    onTap: () {
                                      setState(() {
                                        selectedMethod = method;
                                      });
                                    },
                                  )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('결제 동의', style: AppTheme.titleMedium),
                              const SizedBox(height: 16),
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('결제 진행 및 대여 약관에 동의합니다'),
                                value: agreedToTerms,
                                onChanged: (value) {
                                  setState(() {
                                    agreedToTerms = value ?? false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '총 결제 금액: ${totalPrice ?? 0}원',
                    style: AppTheme.titleMedium.copyWith(
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: !agreedToTerms
                        ? null
                        : () async {
                            final rental = Rental(
                              id: 'R${DateTime.now().millisecondsSinceEpoch}',
                              userId: '',
                              accessoryId: '',
                              stationId: '',
                              accessoryName: accessoryName ?? '',
                              stationName: stationName ?? '',
                              totalPrice: totalPrice ?? 0,
                              status: RentalStatus.active,
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                            );

                            // 결제 완료 후 저장된 정보 삭제
                            final storage = StorageService.instance;
                            await Future.wait([
                              storage.remove('selected_accessory_name'),
                              storage.remove('selected_station_name'),
                              storage.remove('selected_rental_duration'),
                              storage.remove('selected_price'),
                            ]);

                            Navigator.of(context).pushReplacementNamed(
                              Routes.paymentComplete,
                              arguments: rental,
                            );
                          },
                    child: const Text('결제하기'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
