import 'dart:async';

/// A helper transformer which provides *parallel* processing of
/// up to [_futureCountMax] simultaneous futures
class AsyncStreamTransformer<I, O> extends StreamTransformerBase<I, O> {
  final StreamController<O> _controller;
  final Future<O> Function(I) _mapper;
  final int _futureCountMax;

  AsyncStreamTransformer(
    this._mapper, [
    this._futureCountMax = 8,
  ])  : _futureCount = 0,
        _finalizing = false,
        _controller = StreamController<O>();

  int _futureCount;

  bool _finalizing;

  StreamSubscription<I> _subscription;

  @override
  Stream<O> bind(Stream<I> stream) {
    _subscription = stream.listen(_onData);
    _controller.onCancel = _onCancel;
    _controller.onResume = _subscription.resume;
    _controller.onPause = _subscription.pause;
    _subscription.onDone(() {
      _finalizing = true;

      if (_futureCount <= 0) {
        _controller.close();
      }
    });
    return _controller.stream;
  }

  void _onCancel() {
    _subscription.cancel();
    _finalizing = true;
  }

  void Function() _resumeCallback;

  void _onData(I data) {
    final future = _mapper(data);
    _futureCount++;
    future.then(_onFutureResult);
    if (_futureCount >= _futureCountMax) {
      if (_resumeCallback != null) {
        return;
      }
      final completer = Completer<void>();
      _resumeCallback = () {
        completer.complete();
        _resumeCallback = null;
      };
      _subscription.pause(completer.future);
    }
  }

  void _onFutureResult(O result) {
    _futureCount--;
    _controller.add(result);
    if (_futureCount < _futureCountMax && _resumeCallback != null) {
      _resumeCallback();
    }
    if (_finalizing && _futureCount <= 0) {
      _controller.close();
    }
  }
}
