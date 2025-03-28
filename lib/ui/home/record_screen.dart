import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';
import '../widget/recognition_result.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  RecordScreenState createState() =>
      RecordScreenState();
}

class RecordScreenState extends State<RecordScreen> {
  String _currentLocaleId = '';

  void _setCurrentLocale(SpeechToTextProvider speechProvider) {
    if (speechProvider.isAvailable && _currentLocaleId.isEmpty) {
      _currentLocaleId = speechProvider.systemLocale?.localeId ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    var speechProvider = Provider.of<SpeechToTextProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Screen'),
      ),
      body: (speechProvider.isNotAvailable)?
      const Center(
        child: Text(
            'Speech recognition not available, no permission or not available on the device.'),
      ):
      _buildBody(context, speechProvider),
    );
  }

  Widget _buildBody(BuildContext context,SpeechToTextProvider speechProvider) {
    _setCurrentLocale(speechProvider);
    return Column(children: [
      Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              TextButton(
                onPressed:
                !speechProvider.isAvailable || speechProvider.isListening
                    ? null
                    : () => speechProvider.listen(
                    partialResults: true, localeId: _currentLocaleId),
                child: const Text('Start'),
              ),
              TextButton(
                onPressed: speechProvider.isListening
                    ? () => speechProvider.stop()
                    : null,
                child: const Text('Stop'),
              ),
              TextButton(
                onPressed: speechProvider.isListening
                    ? () => speechProvider.cancel()
                    : null,
                child: const Text('Cancel'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              DropdownButton(
                onChanged: (selectedVal) => _switchLang(selectedVal),
                value: _currentLocaleId,
                items: speechProvider.locales
                    .map(
                      (localeName) => DropdownMenuItem(
                    value: localeName.localeId,
                    child: Text(localeName.name),
                  ),
                )
                    .toList(),
              ),
            ],
          )
        ],
      ),
      const Expanded(
        flex: 4,
        child: RecognitionResultsWidget(),
      ),
      Expanded(
        flex: 1,
        child: Column(
          children: <Widget>[
            const Center(
              child: Text(
                'Error Status',
                style: TextStyle(fontSize: 22.0),
              ),
            ),
            Center(
              child: speechProvider.hasError
                  ? Text(speechProvider.lastError!.errorMsg)
                  : Container(),
            ),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        color: Theme.of(context).colorScheme.surface,
        child: Center(
          child: speechProvider.isListening
              ? const Text(
            "I'm listening...",
            style: TextStyle(fontWeight: FontWeight.bold),
          )
              : const Text(
            'Not listening',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ]);
  }

  void _switchLang(selectedVal) {
    setState(() {
      _currentLocaleId = selectedVal;
    });
    debugPrint(selectedVal);
  }
}