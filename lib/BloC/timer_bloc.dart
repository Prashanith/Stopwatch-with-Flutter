import 'package:bloc/bloc.dart';
import 'package:timerapp/BloC/timer_event.dart';
import 'package:timerapp/BloC/timer_state.dart';
import 'package:timerapp/ticker.dart';
import 'package:meta/meta.dart';
import 'dart:async';

class TimerBloc extends Bloc<TimerEvent,TimerState>{
  final int _duration=0;
  //since it is stopwatch duration is 0
  //duration can be set to our own time and few changes in ticker class makes it a timer application
  final Ticker _ticker;
  StreamSubscription<int> _tickerSubscription;

  TimerBloc({@required Ticker ticker})
      :assert(ticker!=null),
        _ticker=ticker;
  @override
  TimerState get initialState => Ready(_duration);

  @override
  Stream<TimerState> mapEventToState(TimerEvent event)async* {
    if (event is Start) {
      yield* _mapStartToState(event);
    } else if (event is Pause) {
      yield* _mapPauseToState(event);
    } else if (event is Resume) {
      yield* _mapResumeToState(event);
    }  else if (event is Reset) {
      yield* _mapResetToState(event);
    } else if (event is Tick) {
      yield* _mapTickToState(event);
    }
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  Stream<TimerState> _mapStartToState(Start start) async* {
    yield Running(start.duration);
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker.tick(ticks: start.duration)
        .listen((duration) => add(Tick(duration: duration)));
  }

  Stream<TimerState> _mapTickToState(Tick tick) async* {
    yield Running(tick.duration);
  }

  Stream<TimerState> _mapResumeToState(Resume resume) async* {
    if (state is Paused) {
      _tickerSubscription?.resume();
      yield Running(state.duration);
    }
  }

  Stream<TimerState> _mapPauseToState(Pause pause) async* {
    if (state is Running) {
      _tickerSubscription?.pause();
      yield Paused(state.duration);
    }
  }

  Stream<TimerState> _mapResetToState(Reset reset) async* {
    _tickerSubscription?.cancel();
    yield Ready(_duration);
  }
}
