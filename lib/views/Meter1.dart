import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projetflutter/models/meterData.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;

FirebaseFirestore firestore = FirebaseFirestore.instance;

class Meter1 extends StatefulWidget {
  @override
  _Meter1State createState() => _Meter1State();
}


class _Meter1State extends State<Meter1> {
  List<MeterData> testValues = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Compteur Électrique')),
      body: _generateBody(context) /* Génération du corps de la page en différé le temps de recevoir les données et ensuite créer le graphique qui les utilise ---- */
    );
  }

  Widget _generateBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('meterElectric') /* réception des données du compteur correspondant ----- */
        .orderBy('date')
        .limitToLast(10)
        .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator(); /* Attente des données ----- */
        } else {
          List<MeterData> meters = snapshot.data.docs
          .map((e) => MeterData.fromMap(e.data()))
          .toList();
        return _generateChart(context, meters);
        }
      });
  }

  Widget _generateChart(BuildContext context, List<MeterData> meters) { /* Génération des graphiques grâce à la librairie flutter_charts */
    testValues = meters;
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        child: Center(
          child:Column(
            children: <Widget>[
              Text('Valeurs récentes',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10.0,
              ),
              Expanded(child: charts.SfCartesianChart(
                primaryXAxis: charts.CategoryAxis(),
                legend: charts.Legend(isVisible: true),
                tooltipBehavior: charts.TooltipBehavior(enable: true),

                series: <charts.LineSeries<MeterData, String>>[
                  charts.LineSeries<MeterData, String>( /* Mapping des valeurs contenues dans les objets /models/MeterData pour les assigner aux axes du graphique ----- */
                    dataSource: testValues, 
                    xValueMapper: (MeterData data, _) => data.date.toString(),
                    yValueMapper: (MeterData data, _) => data.value,
                    dataLabelSettings: charts.DataLabelSettings(isVisible: true))
                ],  
              ))
            ],
          )
        ),
      ),);
  }
}

