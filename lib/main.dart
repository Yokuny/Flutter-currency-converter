import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; //para requisição http
import 'dart:async'; //para esperar o envio das requisições http
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=12b032ab";
void main() async {
  //async para quando os dados do servidor vierem com a requisição do http
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<Map> getData() async {
  //função para requisitar os dados monetarios e esperar para no futuro devolva um map com os valores
  http.Response response = await http.get(request); //faz requisição dos dados
  return json.decode(response.body);
  //pega o corpo da resposta e transforma em arquivo json e depois retorna um <Map>
}

class Home extends StatefulWidget {
  //widget stateful criado com "stful" e o nome
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  double dolar;
  double euro;

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Currency converter \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          //controi no futuro depois de fazer o getData
          builder: (contxt, snapshot) {
            //snapshop pega os dados carregados até o momento
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                    child: Text(
                  "Loading data...",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ));
              default:
                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                    "Loading data error",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ));
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(Icons.monetization_on,
                            size: 150.0, color: Colors.amber),
                        buildTextField(
                            "Reais", "R\$", realController, _realChanged),
                        Divider(),
                        buildTextField(
                            "Dolars", "US\$", dolarController, _dolarChanged),
                        Divider(),
                        buildTextField(
                            "Euros", "€", euroController, _euroChanged),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController coin,
    Function currentCoin) {
  //função que retorna um Widget
  return TextField(
    controller: coin,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    onChanged: currentCoin,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}
