import 'dart:async';
import 'dart:math';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acceleration',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Acceleration'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  AccelerometerEvent event;
  Timer timer;
  StreamSubscription accel;
  double x = 0.0,
      y = 0.0,
      z = 0.0,
      mutlak_ivme = 0,
      sayac = 0.0;

  List<charts.Series<Ivme, double>> _IvmeZaman;
  List<Ivme> xIvme, yIvme, zIvme;
  var d;

  void dispose() {
    timer?.cancel();
    accel?.cancel();
    super.dispose();
  }

  startTimer() {
    if (accel == null) {
      accel = accelerometerEvents.listen((AccelerometerEvent eve) {
        setState(() {
          event = eve;
        });
      });
    } else {
      accel.resume();
    }

    if (timer == null || !timer.isActive) {
      timer = Timer.periodic(Duration(milliseconds: 500), (_) {
        setState(() {
          x = event.x;
          y = event.y;
          z = event.z;
          mutlak_ivme = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2));


          sayac += 1;
          d.add(new Ivme(sayac, mutlak_ivme));

          /*
          _IvmeZaman.add(
            charts.Series(
              colorFn: (__, _) =>
                  charts.ColorUtil.fromDartColor(Colors.red.shade800),
              id: 'Y',
              data: yIvme,
              domainFn: (Ivme ivme, _) => ivme.time,
              measureFn: (Ivme ivme, _) => ivme.ivme,

            ),
          );

          _IvmeZaman.add(
            charts.Series(
              colorFn: (__, _) =>
                  charts.ColorUtil.fromDartColor(Colors.green.shade800),
              id: 'Z',
              data: zIvme,
              domainFn: (Ivme ivme, _) => ivme.time,
              measureFn: (Ivme ivme, _) => ivme.ivme,

            ),
          );
          */
        });
      }
      );
    }
  }

  pauseTimer() {
    // stop the timer and pause the accelerometer stream
    timer.cancel();
    accel.pause();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _IvmeZaman = List<charts.Series<Ivme, double>>();

    d = [
      new Ivme(0, 9)
    ];


    _IvmeZaman.add(
      charts.Series(
        colorFn: (__, _) =>
            charts.ColorUtil.fromDartColor(Colors.purple),
        id: 'X',
        data: d,
        domainFn: (Ivme ivme, _) => ivme.time,
        measureFn: (Ivme ivme, _) => ivme.ivme,

      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xff1976d2),
            bottom: TabBar(
              indicatorColor: Color(0xff9962D0),
              tabs: [
                Tab(icon: Icon(Icons.trending_up),),
                Tab(icon: Icon(Icons.exposure_zero),),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              //Grafik kısmı
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Container(
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: charts.LineChart(
                            _IvmeZaman,
                            animate: false,
                          ),
                        ),
                        Text("Mutlak İvme", style: TextStyle(fontSize: 18),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            RaisedButton(
                              onPressed: startTimer,
                              child: Icon(
                                Icons.play_arrow, color: Colors.white,),
                              color: Colors.red,
                            ),
                            RaisedButton(
                              onPressed: pauseTimer,
                              child: Icon(Icons.pause, color: Colors.white,),
                              color: Colors.red,
                            ),
                          ],
                        ),


                      ],
                    ),
                  ),
                ),
              ),


              //Yazı kısmı
              Center(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text("İvme Ölçcer x: ${x.toStringAsFixed(2)} m/s^2",
                              style: TextStyle(
                                  fontSize: 25, color: Colors.purple),
                            ),
                            Text("İvme Ölçcer y: ${y.toStringAsFixed(2)} m/s^2",
                              style: TextStyle(
                                  fontSize: 25, color: Colors.red.shade800),
                            ),
                            Text("İvme Ölçcer z: ${z.toStringAsFixed(2)} m/s^2",
                              style: TextStyle(
                                  fontSize: 25, color: Colors.green.shade800),
                            ),
                            Text("Mutlak İvme: ${mutlak_ivme.toStringAsFixed(
                                2)} m/s^2",
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.orange.shade800),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          RaisedButton(
                            onPressed: startTimer,
                            child: Icon(Icons.play_arrow, color: Colors.white,),
                            color: Colors.red,
                          ),
                          RaisedButton(
                            onPressed: pauseTimer,
                            child: Icon(Icons.pause, color: Colors.white,),
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )

            ],
          ),
        )
    );
  }


}

class Ivme {
  double time;
  double ivme;

  Ivme(this.time, this.ivme);
}

