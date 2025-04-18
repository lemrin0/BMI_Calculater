import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Localization

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController controlWeight = TextEditingController();
  TextEditingController controlHeight = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _info = '';
  double _bmiValue = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // SAFE: Called after initState() and when dependencies change
    final localizations = AppLocalizations.of(context)!;
    _info = localizations.reportYourData;
  }

  void _resetFields() {
    FocusScope.of(context).unfocus();
    controlHeight.clear();
    controlWeight.clear();

    setState(() {
      _info = AppLocalizations.of(context)!.reportYourData;
      _bmiValue = 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.fieldsReset),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> saveBmiData(double weight, double height, double bmi) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('bmiRecords')
          .add({
        'weight': weight,
        'height': height,
        'bmi': bmi,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.bmiSaved),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void calculate() async {
    double? weight = double.tryParse(controlWeight.text);
    double? height = double.tryParse(controlHeight.text);

    if (weight == null || height == null || height == 0) {
      setState(() {
        _info = AppLocalizations.of(context)!.invalidInput;
        _bmiValue = 0.0;
      });
      return;
    }

    height = height / 100;
    double imc = weight / (height * height);

    setState(() {
      _bmiValue = imc;
      if (imc < 18.6) {
        _info = "${AppLocalizations.of(context)!.belowWeight} (${imc.toStringAsPrecision(4)})";
      } else if (imc <= 24.9) {
        _info = "${AppLocalizations.of(context)!.idealWeight} (${imc.toStringAsPrecision(4)})";
      } else if (imc <= 29.9) {
        _info = "${AppLocalizations.of(context)!.slightlyOverweight} (${imc.toStringAsPrecision(4)})";
      } else if (imc <= 34.9) {
        _info = "${AppLocalizations.of(context)!.obesityGrade1} (${imc.toStringAsPrecision(4)})";
      } else if (imc <= 39.9) {
        _info = "${AppLocalizations.of(context)!.obesityGrade2} (${imc.toStringAsPrecision(4)})";
      } else {
        _info = "${AppLocalizations.of(context)!.obesityGrade3} (${imc.toStringAsPrecision(4)})";
      }
    });

    saveBmiData(weight, height, imc);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.bmiCalculator, style: const TextStyle(fontFamily: "Segoe UI")),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          DropdownButton<Locale>(
            value: Localizations.localeOf(context),
            underline: const SizedBox(),
            icon: const Icon(Icons.language, color: Colors.black),
            onChanged: (Locale? locale) {
              if (locale != null) {
                MyApp.setLocale(context, locale);
              }
            },
            items: const [
              DropdownMenuItem(value: Locale('en'), child: Text('English')),
              DropdownMenuItem(value: Locale('fr'), child: Text('Français')),
              DropdownMenuItem(value: Locale('ar'), child: Text('العربية')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetFields,
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.person, size: 120.0, color: Colors.green),
              TextFormField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.weightLabel,
                  labelStyle: const TextStyle(color: Colors.green),
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.green, fontSize: 25.0),
                controller: controlWeight,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.insertWeight;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.heightLabel,
                  labelStyle: const TextStyle(color: Colors.green),
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.green, fontSize: 25.0),
                controller: controlHeight,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.insertHeight;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50.0,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      calculate();
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text(AppLocalizations.of(context)!.calculate, style: const TextStyle(color: Colors.white, fontSize: 25.0)),
                ),
              ),
              const SizedBox(height: 20),
              _buildBMIGauge(),
              const SizedBox(height: 20),
              Text(
                _info,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.green, fontSize: 25.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBMIGauge() {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 10,
          maximum: 50,
          ranges: <GaugeRange>[
            GaugeRange(startValue: 10, endValue: 18.5, color: Colors.blue, label: AppLocalizations.of(context)!.underweight),
            GaugeRange(startValue: 18.5, endValue: 24.9, color: Colors.green, label: AppLocalizations.of(context)!.normal),
            GaugeRange(startValue: 24.9, endValue: 29.9, color: Colors.yellow, label: AppLocalizations.of(context)!.overweight),
            GaugeRange(startValue: 29.9, endValue: 34.9, color: Colors.orange, label: AppLocalizations.of(context)!.obesity1),
            GaugeRange(startValue: 34.9, endValue: 39.9, color: Colors.red, label: AppLocalizations.of(context)!.obesity2),
            GaugeRange(startValue: 40, endValue: 50, color: Colors.purple, label: AppLocalizations.of(context)!.obesity3),
          ],
          pointers: <GaugePointer>[NeedlePointer(value: _bmiValue, enableAnimation: true)],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Text(
                "${_bmiValue.toStringAsPrecision(4)}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              positionFactor: 0.8,
              angle: 90,
            ),
          ],
        ),
      ],
    );
  }
}
