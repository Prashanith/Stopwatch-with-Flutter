import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:timerapp/BloC/timer_bloc.dart';
import 'package:timerapp/BloC/timer_event.dart';
import 'package:timerapp/BloC/timer_state.dart';
import 'package:timerapp/ticker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        title: 'Stopwatch',
        home: BlocProvider(
          create: (context) => TimerBloc(ticker: Ticker()),
          child: Timer(),
        ),
      ),
    );
  }
}

class Timer extends StatefulWidget {
  static const TextStyle timerTextStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w300,
    color: Colors.tealAccent,
  );
  static const TextStyle millisecondsStrStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w100,
    color: Colors.tealAccent,
  );
  static const TextStyle appBarStyle=TextStyle(
    color: Colors.tealAccent,
  );

  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<Timer> {
  ScrollController _scrollController=ScrollController();
  final lapKey =GlobalKey<AnimatedListState>();
  List<String> laps=[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: GestureDetector(
            child:Text('Stopwatch',style:Timer.appBarStyle,),
            onTap:()=>toast('A Dev007 App',duration: Duration(seconds:1))
        ),centerTitle: true,
      backgroundColor: Colors.cyan[900],
      ),
      body:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            radius: 80,
            backgroundColor: Colors.cyan[900],
            child: BlocBuilder<TimerBloc, TimerState>(
              builder: (context, state){
                //logic of time in seconds,minutes and hours
                final String hoursStr =((state.duration/3600)%3600).floor().toString().padLeft(2,'0');
                final String minutesStr = ((state.duration/ 60) % 60)
                    .floor()
                    .toString()
                    .padLeft(2, '0');
                final String secondsStr = (state.duration % 60)
                    .floor()
                    .toString()
                    .padLeft(2, '0');

                //UI logic
                return Column(
                  //time display
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 20,),
                    Text('$hoursStr:$minutesStr:$secondsStr',style: Timer.timerTextStyle,),
                    SizedBox(height: 10,),
                    GestureDetector(
                      child: Text('Lap',style: TextStyle(color:Colors.tealAccent,fontSize: 20),),
                      onTap: (){
                        if(state is !Running){}
                        if(state is Running){
                          int index=0;
                          if(laps.length==0){
                            laps.insert(index,'$hoursStr:$minutesStr:$secondsStr');
                            }
                          else{
                            index=laps.length;
                            laps.insert(index,'$hoursStr:$minutesStr:$secondsStr');
                          }
                        }
                        setState(() {
                          _scrollController.animateTo(
                            _scrollController.offset+30,
                            curve: Curves.bounceIn,
                            duration: const Duration(milliseconds: 300),
                          );
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 10.0,),

          //actions:pause,reset,resume,start
          BlocBuilder<TimerBloc, TimerState>(
            condition: (previousState, currentState) =>
            currentState.runtimeType != previousState.runtimeType,
            builder: (context, state) => Actions(),
          ),
          SizedBox(height: 10.0,),

          //laps list and UI
          BlocBuilder<TimerBloc, TimerState>(
              builder: (context, state) {
              if(state is Ready){
                laps.clear();
                return SizedBox(height: 0,);
              }
              return Container(
                constraints: BoxConstraints(
                  maxHeight: 150,
                  minHeight: 20

                ),
                child: ListView.builder(
                  itemCount: laps.length,
                    itemExtent:30,
                    key: lapKey,
                    reverse: true,
                    shrinkWrap: true,
                    physics:BouncingScrollPhysics(),
                    controller:_scrollController,
                    itemBuilder: (context,index){
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: Text('#${index+1} : ${laps[index]}',style:TextStyle(color: Colors.white,fontSize: 20)),
                          ),
                        ],
                      );
                    }),
              );
            }
          ),
        ],
      )

    );
  }
}

class Actions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _mapStateToActionButtons(
        timerBloc: BlocProvider.of<TimerBloc>(context),
      ),
    );
  }
  List<Widget> _mapStateToActionButtons({
    TimerBloc timerBloc,
  }) {
    final TimerState currentState = timerBloc.state;
    //ready state: return only start button
    if (currentState is Ready) {
      return [
        FloatingActionButton(
          elevation:0 ,
          child: Icon(Icons.play_arrow),
          backgroundColor: Colors.cyan[900],
          onPressed: () =>
              timerBloc.add(Start(duration:currentState.duration)),
        ),
      ];
    }

    //running state:return pause and reset buttons
    if (currentState is Running) {
      return [
        FloatingActionButton(
          elevation:0 ,
          child: Icon(Icons.pause),
          onPressed: () => timerBloc.add(Pause()),
          backgroundColor: Colors.cyan[900],
        ),
        SizedBox(width: 20,),
        FloatingActionButton(
          elevation:0 ,
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(Reset()),
          backgroundColor: Colors.cyan[900],
        ),
      ];
    }

    //pause state:return play and reset buttons
    if (currentState is Paused) {
      return [
        FloatingActionButton(
          elevation:0 ,
          child: Icon(Icons.play_arrow),
          onPressed: () => timerBloc.add(Resume()),
          backgroundColor: Colors.cyan[900],
        ),
        SizedBox(width: 20,),
        FloatingActionButton(
          elevation:0 ,
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(Reset()),
          backgroundColor: Colors.cyan[900],
        ),
      ];
    }
    return [];
  }
}
