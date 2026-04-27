import 'package:bingo_admin/Upload/ads.dart';
import 'package:bingo_admin/Upload/adsedit.dart';
import 'package:bingo_admin/Upload/upload.dart';
import 'package:bingo_admin/Upload/upload_offer.dart';
import 'package:bingo_admin/Upload/upload_offer_edit.dart';
import 'package:bingo_admin/Upload/uploadedit.dart';
import 'package:flutter/material.dart';

class UploadPage extends StatelessWidget {
  final String token;

  const UploadPage({
    super.key,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Upload Details'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Upload'),
              Tab(text: 'Upload View'),
              Tab(text: 'Offer'),
              Tab(text: 'Offer View'),
              Tab(text: 'Ads'),
              Tab(text: 'Ads View'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Upload(token: token),
            UploadEdit(token: token),
            const UploadOffer(),
            const UploadOfferEdit(),
            const Ads(),
            const AdsEdit(),
          ],
        ),
      ),
    );
  }
}