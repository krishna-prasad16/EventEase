import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:user/Screens/success.dart';
import 'package:user/main.dart';

class PaymentGatewayScreen extends StatefulWidget {
  final int id;
  final int amt;
  final bool isCatering; // Add this flag

  const PaymentGatewayScreen({
    super.key,
    required this.id,
    required this.amt,
    this.isCatering = false, // Default to false for decoration
  });

  @override
  _PaymentGatewayScreenState createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  Future<void> checkout() async {
    try {
      if (widget.isCatering) {
        // Update catering booking
        await supabase.from('tbl_cateringbooking').update({
          'booking_status': 3,
          'booking_total': widget.amt,
        }).eq('id', widget.id);
      } else {
        // Update decoration booking
        await supabase.from('tbl_decorationbooking').update({
          'decbook_status': 3,
          'decbook_totalamnt': widget.amt,
        }).eq('decbook_id', widget.id);
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PaymentSuccessPage()),
      );
    } catch (e) {
      print(e);
    }
  }

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Gateway'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 226, 209, 255), const Color.fromARGB(255, 255, 255, 255)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              CreditCardWidget(
                floatingConfig: FloatingConfig(
                  isGlareEnabled: true,
                  isShadowEnabled: true
                ),
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,
                showBackView: isCvvFocused,
                onCreditCardWidgetChange: (creditCardBrand) {},
                isHolderNameVisible: true,
                enableFloatingCard: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CreditCardForm(
                        cardNumber: cardNumber,
                        expiryDate: expiryDate,
                        cardHolderName: cardHolderName,
                        cvvCode: cvvCode,
                        isHolderNameVisible: true,
                        onCreditCardModelChange: (creditCardModel) {
                          setState(() {
                            cardNumber = creditCardModel.cardNumber;
                            expiryDate = creditCardModel.expiryDate;
                            cardHolderName = creditCardModel.cardHolderName;
                            cvvCode = creditCardModel.cvvCode;
                            isCvvFocused = creditCardModel.isCvvFocused;
                          });
                        },
                        formKey: formKey,
                        cardNumberValidator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          }
                          if (value.length != 19) {
                            return 'Invalid card number';
                          }
                          return null;
                        },
                        expiryDateValidator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          }
                          if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                            return 'Invalid expiry date format';
                          }
                          final List<String> parts = value.split('/');
                          final int month = int.tryParse(parts[0]) ?? 0;
                          final int year = int.tryParse(parts[1]) ?? 0;
                          final DateTime now = DateTime.now();
                          final int currentYear = now.year % 100;
                          final int currentMonth = now.month;
                          if (month < 1 || month > 12) {
                            return 'Invalid month';
                          }
                          if (year < currentYear ||
                              (year == currentYear && month < currentMonth)) {
                            return 'Card has expired';
                          }
                          return null;
                        },
                        cvvValidator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          }
                          if (value.length < 3) {
                            return 'Invalid CVV';
                          }
                          return null;
                        },
                        cardHolderValidator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          }
                          if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                            return 'Invalid cardholder name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            checkout();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Please fill in all fields correctly!')),
                            );
                          }
                        },
                        child: Text(
                          'Pay Now',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}