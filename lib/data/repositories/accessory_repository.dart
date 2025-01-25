import '../models/accessory.dart';

class AccessoryRepository {
  Future<List<Accessory>> getAll() async {
    // 시뮬레이션을 위한 더미 데이터
    await Future.delayed(const Duration(seconds: 1));
    return [
      // 충전기
      Accessory(
        id: 'charger-1',
        name: '노트북 고출력 충전기',
        description: '100W PD 고속 충전기',
        pricePerHour: 2000,
        category: AccessoryCategory.charger,
        isAvailable: true,
        imageUrl: 'assets/images/charger-1.png',
      ),
      Accessory(
        id: 'charger-2',
        name: '노트북 PD 충전기',
        description: '65W PD 충전기',
        pricePerHour: 1500,
        category: AccessoryCategory.charger,
        isAvailable: true,
        imageUrl: 'assets/images/charger-2.png',
      ),
      Accessory(
        id: 'charger-3',
        name: 'C타입 충전기',
        description: '25W 고속 충전기',
        pricePerHour: 1000,
        category: AccessoryCategory.charger,
        isAvailable: true,
        imageUrl: 'assets/images/charger-3.png',
      ),
      Accessory(
        id: 'charger-4',
        name: '8핀 충전기',
        description: '20W 고속 충전기',
        pricePerHour: 1000,
        category: AccessoryCategory.charger,
        isAvailable: true,
        imageUrl: 'assets/images/charger-4.png',
      ),

      // 케이블
      Accessory(
        id: 'cable-1',
        name: 'HDMI 케이블',
        description: '4K 지원 HDMI 2.0',
        pricePerHour: 1000,
        category: AccessoryCategory.cable,
        isAvailable: true,
        imageUrl: 'assets/images/cable-1.png',
      ),
      Accessory(
        id: 'cable-2',
        name: 'DP 케이블',
        description: '4K 지원 DisplayPort 1.4',
        pricePerHour: 1000,
        category: AccessoryCategory.cable,
        isAvailable: true,
        imageUrl: 'assets/images/cable-2.png',
      ),
      Accessory(
        id: 'cable-3',
        name: 'C to C 케이블',
        description: '100W PD 지원',
        pricePerHour: 500,
        category: AccessoryCategory.cable,
        isAvailable: true,
        imageUrl: 'assets/images/cable-3.png',
      ),
      Accessory(
        id: 'cable-4',
        name: 'C to A 케이블',
        description: '고속 데이터 전송',
        pricePerHour: 500,
        category: AccessoryCategory.cable,
        isAvailable: true,
        imageUrl: 'assets/images/cable-4.png',
      ),

      // 독
      Accessory(
        id: 'dock-1',
        name: 'SD 카드 독 (Type-C)',
        description: 'SD/MicroSD 지원',
        pricePerHour: 1500,
        category: AccessoryCategory.dock,
        isAvailable: true,
        imageUrl: 'assets/images/dock-1.png',
      ),
      Accessory(
        id: 'dock-2',
        name: 'USB 독 (Type-C)',
        description: 'USB 3.0 4포트',
        pricePerHour: 1500,
        category: AccessoryCategory.dock,
        isAvailable: true,
        imageUrl: 'assets/images/dock-2.png',
      ),
      Accessory(
        id: 'dock-3',
        name: '멀티 독 (Type-C)',
        description: 'HDMI, USB, SD 카드 지원',
        pricePerHour: 2000,
        category: AccessoryCategory.dock,
        isAvailable: true,
        imageUrl: 'assets/images/dock-3.png',
      ),

      // 보조배터리
      Accessory(
        id: 'powerbank-1',
        name: '노트북용 보조배터리',
        description: '30000mAh, 100W PD',
        pricePerHour: 3000,
        category: AccessoryCategory.powerBank,
        isAvailable: true,
        imageUrl: 'assets/images/powerbank-1.png',
      ),
      Accessory(
        id: 'powerbank-2',
        name: '휴대폰용 보조배터리',
        description: '10000mAh, 25W',
        pricePerHour: 1500,
        category: AccessoryCategory.powerBank,
        isAvailable: true,
        imageUrl: 'assets/images/powerbank-2.png',
      ),

      // 기타
      Accessory(
        id: 'etc-1',
        name: '발표용 리모콘',
        description: '레이저 포인터 내장',
        pricePerHour: 1000,
        category: AccessoryCategory.etc,
        isAvailable: true,
        imageUrl: 'assets/images/etc-1.png',
      ),
    ];
  }

  Future<Accessory> get(String id) async {
    final accessories = await getAll();
    return accessories.firstWhere((a) => a.id == id);
  }
}
