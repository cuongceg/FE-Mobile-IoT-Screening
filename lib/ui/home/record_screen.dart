import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text_iot_screen/providers/custom_stt_provider.dart';
import 'package:speech_to_text_iot_screen/services/web_socket_services.dart';
import '../widget/recognition_result.dart';

class RecordScreen extends StatefulWidget {
  final String title,description;
  const RecordScreen({super.key,required this.description,required this.title});

  @override
  RecordScreenState createState() =>
      RecordScreenState();
}

class RecordScreenState extends State<RecordScreen> {
  late WebSocketServices _webSocketServices ;
  String _currentLocaleId = '';

  void _setCurrentLocale(CustomSttProvider speechProvider) {
    if (speechProvider.isAvailable && _currentLocaleId.isEmpty) {
      _currentLocaleId = speechProvider.systemLocale?.localeId ?? '';
    }
  }
  @override
  void initState() {
    super.initState();
    _webSocketServices = WebSocketServices(userId: "t1",
        title: widget.title,
        description: widget.description,);
  }

  @override
  void dispose() {
    _webSocketServices.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var speechProvider = Provider.of<CustomSttProvider>(context);
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

  Widget _buildBody(BuildContext context,CustomSttProvider speechProvider) {
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
                    : () {
                  speechProvider.listen(
                      partialResults: true, localeId: _currentLocaleId,webSocketServices: _webSocketServices);
                },
                child: const Text('Start'),
              ),
              TextButton(
                onPressed: speechProvider.isListening
                    ? () =>{
                      speechProvider.stop()
                }
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