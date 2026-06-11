import 'package:cinemind/shared/widget/card/tv_card_poster.dart';
import 'package:flutter/material.dart';
import 'package:cinemind/model/tv_series.dart';
import 'package:cinemind/shared/service/tv_serie_service.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late final Future<TvSerie?> _tvFuture;
  final TvSerieService _service = TvSerieService();

  @override
  void initState() {
    super.initState();
    // start fetching once
    _tvFuture = _service.fetchTvSerieByID(1399);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test TV')),
      body: FutureBuilder<TvSerie?>(
        future: _tvFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // loading
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // unexpected error
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final tv = snapshot.data;
          if (tv == null) {
            // service returned null (not found or fetch failed)
            return const Center(
              child: Text(
                'TV series not found.',
                textAlign: TextAlign.center,
              ),
            );
          }

          // success — show your card
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: TvSerieCard(
                  tvSerie:
                      tv), // or TvCardSliding / TvSerieCard depending on your widget
            ),
          );
        },
      ),
    );
  }
}
