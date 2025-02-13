const functions = require('firebase-functions');
const { db } = require('../../utils/db');
const { approvePayment } = require('../../utils/pgService');

/**
 * 연장 결제 승인 및 저장
 * POST /payments/approve-renewal
 * Request: PaymentRenewalConfirmRequest
 */
exports.approveRenewalPayment = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({
      success: false,
      message: '허용되지 않는 메소드입니다.'
    });
  }

  // Firestore 트랜잭션 시작
  const transaction = db.runTransaction(async (t) => {
    try {
      const { 
        payments: { orderId, paymentKey, amount },
        rentals: { rentalHistoryToken, renewalTime }
      } = req.body;

      // 요청 데이터 검증
      if (!orderId || !paymentKey || !amount || !rentalHistoryToken || !renewalTime) {
        return res.status(400).json({
          success: false,
          message: '필수 파라미터가 누락되었습니다.'
        });
      }

      // 대여 이력 조회
      const rentalHistoryRef = db.collection('rental_history').doc(rentalHistoryToken);
      const rentalHistoryDoc = await t.get(rentalHistoryRef);

      if (!rentalHistoryDoc.exists) {
        throw new Error('존재하지 않는 대여 이력입니다.');
      }

      const rentalHistory = rentalHistoryDoc.data();

      // 대여 상태 확인 (Rented 상태만 연장 가능)
      if (rentalHistory.status !== 'Rented') {
        throw new Error('연장이 불가능한 상태입니다.');
      }

      // PG사 결제 승인 요청
      const paymentResult = await approvePayment({
        paymentKey,
        orderId,
        amount
      });

      if (!paymentResult.success) {
        throw new Error('결제 승인에 실패했습니다.');
      }

      // 결제 내역 저장
      const paymentRef = db.collection('rental_payments').doc();
      t.set(paymentRef, {
        type: 'credit_card',                                    // 결제 유형 (연장)
        total_amount: parseInt(amount),                     // 결제 총액
        payment_date: admin.firestore.FieldValue.serverTimestamp(), // 결제 일시
        order_id: orderId,                                 // 주문 ID
        rental_history_id: rentalHistoryToken              // 대여 이력 ID
      });

      // 대여 이력 업데이트
      const currentEndTime = rentalHistory.end_time.toDate();
      const newEndTime = new Date(currentEndTime.getTime() + (renewalTime * 60 * 60 * 1000));
      const newRentalTime = rentalHistory.rental_time + renewalTime;

      t.update(rentalHistoryRef, {
        end_time: newEndTime,           // 연장된 반납 예정 시간
        rental_time: newRentalTime      // 증가된 총 대여 시간
      });

      return {
        paymentId: paymentRef.id,
        endTime: newEndTime,
        rentalTime: newRentalTime
      };
    } catch (error) {
      throw error;
    }
  });

  try {
    const result = await transaction;

    return res.status(200).json({
      success: true,
      data: {
        paymentId: result.paymentId,
        endTime: result.endTime,
        rentalTime: result.rentalTime,
        message: '연장 결제가 완료되었습니다.'
      }
    });

  } catch (error) {
    console.error('Approve renewal payment error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || '서버 오류가 발생했습니다.'
    });
  }
});
