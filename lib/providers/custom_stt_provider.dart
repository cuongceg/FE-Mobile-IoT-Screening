import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_event.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text_iot_screen/services/web_socket_services.dart';

class CustomSttProvider extends ChangeNotifier {
  final Duration _interval = const Duration(seconds: 5);
  final StringBuffer _buffer = StringBuffer();
  int _lastSaveIndex = 0;
  Timer? _timer;
  final StreamController<SpeechRecognitionEvent> _recognitionController =
  StreamController.broadcast();
  final SpeechToText _speechToText;
  SpeechRecognitionResult? _lastResult;
  double _lastLevel = 0;
  List<LocaleName> _locales = [];
  LocaleName? _systemLocale;

  /// Only construct one instance in an application.
  ///
  /// Do not call `initialize` on the [SpeechToText] that is passed as a parameter, instead
  /// call the [initialize] method on this class.
  CustomSttProvider(this._speechToText);

  Stream<SpeechRecognitionEvent> get stream => _recognitionController.stream;

  /// Returns the last result received.
  SpeechRecognitionResult? get lastResult => _lastResult;

  /// Returns the last error received.
  SpeechRecognitionError? get lastError => _speechToText.lastError;

  /// Returns the last sound level received.
  ///
  /// Note this is only available when the `soundLevel` is set to true on
  /// a call to [listen], will be 0 at all other times.
  double get lastLevel => _lastLevel;

  /// Initializes the provider and the contained [SpeechToText] instance.
  ///
  /// Returns true if [SpeechToText] was initialized successful and can now
  /// be used, false otherwise.
  Future<bool> initialize(
      {debugLogging = false,
        Duration finalTimeout = SpeechToText.defaultFinalTimeout,
        List<SpeechConfigOption>? options}) async {
    if (isAvailable) {
      return isAvailable;
    }
    var availableBefore = _speechToText.isAvailable;
    var available = await _speechToText.initialize(
        onStatus: (String status) =>_onStatus(status),
        onError: _onError,
        debugLogging: debugLogging,
        finalTimeout: finalTimeout,
        options: options);
    if (available) {
      _locales = [];
      _locales.addAll(await _speechToText.locales());
      _systemLocale = await _speechToText.systemLocale();
    }
    if (availableBefore != available) {
      notifyListeners();
    }
    return available;
  }

  /// Returns true if the provider has been initialized and can be used to recognize speech.
  bool get isAvailable => _speechToText.isAvailable;

  /// Returns true if the provider cannot be used to recognize speech, either because it has not
  /// yet been initialized or because initialization failed.
  bool get isNotAvailable => !_speechToText.isAvailable;

  /// Returns true if [SpeechToText] is listening for new speech.
  bool get isListening => _speechToText.isListening;

  /// Returns true if [SpeechToText] is not listening for new speech.
  bool get isNotListening => _speechToText.isNotListening;

  /// Returns true if [SpeechToText] has a previous error.
  bool get hasError => _speechToText.hasError;

  /// Returns true if [lastResult] has a last result.
  bool get hasResults => null != _lastResult;

  /// Returns the list of locales that are available on the device for speech recognition.
  List<LocaleName> get locales => _locales;

  /// Returns the locale that is currently set as active on the device.
  LocaleName? get systemLocale => _systemLocale;

  /// Start listening for new events, set [partialResults] to true to receive interim
  /// recognition results.
  ///
  /// [partialResults] if true the listen reports results as they are recognized,
  /// when false only final results are reported. Defaults to true.
  ///
  /// [onDevice] if true the listen attempts to recognize locally with speech never
  /// leaving the device. If it cannot do this the listen attempt will fail. This is
  /// usually only needed for sensitive content where privacy or security is a concern.
  ///
  /// [soundLevel] set to true to be notified on changes to the input sound level
  /// on the microphone.
  ///
  /// [listenFor] sets the maximum duration that it will listen for, after
  /// that it automatically stops the listen for you.
  ///
  /// [pauseFor] sets the maximum duration of a pause in speech with no words
  /// detected, after that it automatically stops the listen for you.
  ///
  /// [localeId] is an optional locale that can be used to listen in a language
  /// other than the current system default. See [locales] to find the list of
  /// supported languages for listening.
  ///
  /// Call this only after a successful [initialize] call
  void listen(
      {bool partialResults = true,
        onDevice = false,
        bool soundLevel = false,
        Duration? listenFor,
        Duration? pauseFor,
        String? localeId,
        WebSocketServices? webSocketServices,
        ListenMode listenMode = ListenMode.confirmation}) {
    _lastLevel = 0;
    _lastResult = null;
    final options = SpeechListenOptions(
        partialResults: partialResults,
        onDevice: onDevice,
        cancelOnError: true,
        listenMode: listenMode);
    if (soundLevel) {
      _speechToText.listen(
          listenFor: listenFor,
          pauseFor: pauseFor,
          onResult:(result) =>_onListenResult(result,webSocketServices),
          onSoundLevelChange: _onSoundLevelChange,
          localeId: localeId,
          listenOptions: options);
    } else {
      _speechToText.listen(
          listenFor: listenFor,
          pauseFor: pauseFor,
          onResult: (result)=> _onListenResult(result, webSocketServices),
          localeId: localeId,
          listenOptions: options);
    }
  }

  /// Stops a current active listening session.
  ///
  /// Call this after calling [listen] to stop the recognizer from listening further
  /// and return the current result as final.
  void stop() {
    _speechToText.stop();
    notifyListeners();
  }

  /// Cancel a current active listening session.
  ///
  /// Call this after calling [listen] to stop the recognizer from listening further
  /// and ignore any results recognized so far.
  void cancel() {
    _speechToText.cancel();
    notifyListeners();
  }

  void _onError(SpeechRecognitionError errorNotification) {
    _recognitionController.add(SpeechRecognitionEvent(
        SpeechRecognitionEventType.errorEvent,
        null,
        errorNotification,
        isListening,
        null));
    notifyListeners();
  }

  void _onStatus(String status) {
    if (status == SpeechToText.doneStatus) {
      _recognitionController.add(SpeechRecognitionEvent(
          SpeechRecognitionEventType.doneEvent, null, null, isListening, null));
    } else {
      _recognitionController.add(SpeechRecognitionEvent(
          SpeechRecognitionEventType.statusChangeEvent,
          null,
          null,
          isListening,
          null));
    }
    notifyListeners();
  }

  void _onListenResult(SpeechRecognitionResult result,WebSocketServices? webSocketServices) {
    _lastResult = result;
    //debugPrint("${_timer == null}");
    if(_timer == null){
      _startTimer(() {
        //debugPrint("Timer called");
        if (_lastResult != null && webSocketServices != null && _lastResult!.recognizedWords.length > _lastSaveIndex) {
          _buffer.write(_lastResult!.recognizedWords.substring(_lastSaveIndex));
          webSocketServices.sendBufferIfNotEmpty(buffer: _buffer,isEnd: false);
          _buffer.clear();
          _lastSaveIndex = _lastResult!.recognizedWords.length;
        }
      });
    }

    if (result.finalResult) {
      _stopTimer(() {
        if(webSocketServices != null && result.recognizedWords.length > _lastSaveIndex){
          _buffer.write(result.recognizedWords.substring(_lastSaveIndex));
          webSocketServices.sendBufferIfNotEmpty(buffer: _buffer,isEnd: true);
          _buffer.clear();
        }
      });
    }
    _recognitionController.add(SpeechRecognitionEvent(
        result.finalResult
            ? SpeechRecognitionEventType.finalRecognitionEvent
            : SpeechRecognitionEventType.partialRecognitionEvent,
        result,
        null,
        isListening,
        null));
    notifyListeners();
  }

  void _onSoundLevelChange(double level) {
    _lastLevel = level;
    _recognitionController.add(SpeechRecognitionEvent(
        SpeechRecognitionEventType.soundLevelChangeEvent,
        null,
        null,
        null,
        level));
    notifyListeners();
  }

  /// Starts a timer that will call the provided callback function at regular intervals.
  void _startTimer(void Function() callback) {
    _timer = Timer.periodic(_interval, (timer) {
      callback();
    });
  }

  void _stopTimer(void Function() callback) {
    _timer?.cancel();
    callback();
    _timer = null;
    _lastSaveIndex = 0;
  }
}