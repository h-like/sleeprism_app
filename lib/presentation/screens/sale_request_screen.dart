import 'package:flutter/material.dart';

/// 판매 요청 상세 정보를 보여주는 화면입니다. (임시 Placeholder)
class SaleRequestScreen extends StatelessWidget {
  final int saleRequestId;
  const SaleRequestScreen({super.key, required this.saleRequestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('판매 요청 ID: $saleRequestId'),
      ),
      body: Center(
        child: Text('여기에 판매 요청 상세 정보가 표시됩니다.'),
      ),
    );
  }
}