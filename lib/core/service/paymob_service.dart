import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:medical_service_app/core/utils/constants/constants.dart';

Future<String> generatePayMobPaymentKey({
  required int amount,
  required String doctorId,
  required DateTime appointmentDate,
  required String appointmentTime,
}) async {
  try {
    const String apiKey = paymobapikey; // ضيفي مفتاح Paymob بتاعك هنا
    const int integrationId = 5236319; // ID بتاع الـ Iframe اللي في حسابك
    // 1️⃣ Auth Token
    final authResp = await http.post(
      Uri.parse("https://accept.paymob.com/api/auth/tokens"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"api_key": apiKey}),
    );
    final authData = jsonDecode(authResp.body);
    final authToken = authData["token"];
    debugPrint("Auth Response: ${authResp.body}");

    if (authToken == null) throw Exception("Auth token not received!");

    // 2️⃣ Order
    final orderResp = await http.post(
      Uri.parse("https://accept.paymob.com/api/ecommerce/orders"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $authToken",
      },

      body: jsonEncode({
        "amount_cents": amount, // لازم يكون بـ cents (x100)
        "currency": "EGP",
        "items": [
          {"name": "Doctor Appointment", "amount_cents": amount, "quantity": 1},
        ],
      }),
    );
    final orderData = jsonDecode(orderResp.body);
    final orderId = orderData["id"];
    if (orderId == null) throw Exception("Order ID not received!");

    // 3️⃣ Payment Key
    final paymentKeyResp = await http.post(
      Uri.parse("https://accept.paymob.com/api/acceptance/payment_keys"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $authToken", // ✅ ضروري جدًا
      },
      body: jsonEncode({
        "amount_cents": amount,
        "currency": "EGP",
        "order_id": orderId,
        "billing_data": {
          "apartment": "NA",
          "email": "test@example.com",
          "first_name": "Patient",
          "building": "1", // ✅ مضافة
          "floor": "1", // ✅ مضافة
          "last_name": "User",
          "street": "Cairo",
          "city": "Cairo",
          "country": "EG",
          "phone_number": "+201234567890",
        },
        "integration_id": integrationId,
      }),
    );

    debugPrint("Payment Key Response: ${paymentKeyResp.body}");

    final paymentKeyData = jsonDecode(paymentKeyResp.body);
    final paymentToken = paymentKeyData["token"];

    if (paymentToken == null) {
      throw Exception(
        "Payment Key not received. Check integrationId and authToken!",
      );
    }

    debugPrint("✅ Payment Key generated successfully!");
    return paymentToken;
  } catch (e) {
    debugPrint("❌ Error generating PayMob Payment Key: $e");
    rethrow;
  }
}
