import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';  // Import the localization package

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("Not logged in"));

    final loc = AppLocalizations.of(context)!;  // Access localized strings

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.history),  // Translated history title
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('bmiRecords')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = snapshot.data?.docs ?? [];

          if (records.isEmpty) {
            return Center(child: Text(loc.noBmiRecords));  // Translated no records message
          }

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final data = records[index].data() as Map<String, dynamic>;
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
              final dateStr = timestamp != null
                  ? DateFormat('yyyy-MM-dd HH:mm').format(timestamp)
                  : loc.noDate;  // Translated "No date" message

              return ListTile(
                title: Text("${loc.bmi}: ${data['bmi'].toStringAsFixed(2)}"),  // Translated BMI text
                subtitle: Text("${loc.weight}: ${data['weight']}kg, ${loc.height}: ${data['height']}cm\n$dateStr"),  // Translated weight and height
              );
            },
          );
        },
      ),
    );
  }
}