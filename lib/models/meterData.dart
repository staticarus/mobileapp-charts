/* Modèle pour les valeurs firestore des compteurs, qui sont utilisées sous forme d'objets pour l'affichage des graphiques */

class MeterData {
  int value;
  String date;
  
  MeterData(int value, String date){
    this.value = value;
    this.date = date;
  }

  MeterData.fromMap(Map<String, dynamic> map)
  : assert(map['value'] != null),
    assert(map['date'] != null),
    value = map['value'],
    date = map['date'].toDate().toString();
}