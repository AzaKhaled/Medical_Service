// lib/features/payment/payment_view.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentView extends StatefulWidget {
  const PaymentView({super.key});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  late final WebViewController _controller;
  Map<String, dynamic>? args;
  final supabase = Supabase.instance.client;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ نمنع التكرار لو اتعمل rebuild
    if (args != null) return;

    args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      final paymentKey = args!['paymentKey'] as String;
      final iframeId = args!['iframeId'].toString();
      final amount = args!['amount'] ?? 0;
      final userId = args!['userId'] as String?;
      final doctorId = args!['doctorId'] as String?;
      final appointmentId = args!['appointmentId'] as String?;

      final url =
          "https://accept.paymob.com/api/acceptance/iframes/$iframeId?payment_token=$paymentKey";

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (url) async {
              debugPrint("🌐 Navigating to: $url");
              debugPrint(
                "🔍 argsssssssssssssssssssssssssssssssssssssssssssssssssss: $args",
              );

              // ✅ Check for success / failure URLs
              if (url.contains("payment-success") ||
                  url.contains("success=true")) {
                debugPrint("✅ Payment success detected");
                if (userId != null &&
                    doctorId != null &&
                    appointmentId != null) {
                  await savePaymentToSupabase(
                    userId: userId,
                    doctorId: doctorId,
                    appointmentId: appointmentId,
                    amount: (amount is num)
                        ? amount.toInt()
                        : int.tryParse(amount.toString()) ?? 0,

                    status: "paid",
                  );
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('payment successful')),
                  );
                  Navigator.pop(context, true);
                }
              } else if (url.contains("payment-failed") ||
                  url.contains("failed=true") ||
                  url.contains("declined")) {
                debugPrint("❌ Payment failed/declined");
                if (userId != null &&
                    doctorId != null &&
                    appointmentId != null) {
                  await savePaymentToSupabase(
                    userId: userId,
                    doctorId: doctorId,
                    appointmentId: appointmentId,
                    amount: amount is int
                        ? amount
                        : int.tryParse(amount.toString()) ?? 0,
                    status: "failed",
                  );
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('payment failed or declined')),
                  );
                  Navigator.pop(context, false);
                }
              }
            },
            onWebResourceError: (err) {
              debugPrint("WebView error: ${err.description}");
            },
          ),
        )
        ..loadRequest(Uri.parse(url));
    }
  }

  /// ✅ حفظ بيانات الدفع في Supabase
  Future<void> savePaymentToSupabase({
    required String userId,
    required String doctorId,
    required String appointmentId,
    required int amount,
    required String status,
  }) async {
    try {
      debugPrint("🟢 Saving payment to Supabase...");
      debugPrint("userId: $userId");
      debugPrint("doctorId: $doctorId");
      debugPrint("appointmentId: $appointmentId");
      debugPrint("amount: $amount, status: $status");

      final res = await supabase
          .from('payments')
          .insert({
            'user_id': userId,
            'doctor_id': doctorId,
            'appointment_id': appointmentId,
            'amount': amount,
            'status': status,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .maybeSingle();

      debugPrint("✅ Payment saved to Supabase: $res");
    } catch (e, st) {
      debugPrint("❌ Error saving payment: $e");
      debugPrint(st.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
      ),
      body: args == null
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(controller: _controller),
    );
  }
}
