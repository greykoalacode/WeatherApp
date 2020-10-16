import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main(){
  runApp(WeatherApp(),
  );
}

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  int temperature;
  String location='San Fransisco';
  int woeid=2487956;
  String weather='clear';
  String abbrevation='';
  String errorMessage="";

  String searchApiUrl='https://www.metaweather.com/api/location/search/?query=';
  String locationApiUrl='https://www.metaweather.com/api/location/';

  initState() {
    super.initState();
    fetchLocation();
  }

  void fetchSearch(String input) async{
    try {
      var searchResult = await http.get(searchApiUrl + input);
      var result = json.decode(searchResult.body)[0];

      setState(() {
        location = result["title"];
        woeid = result["woeid"];
        errorMessage="";
      });
    }
    catch(error){
      setState(() {
        errorMessage="Sorry we dont't have data about this city";
      });
    }
  }

  void fetchLocation() async{
    var locationResult=await http.get(locationApiUrl + woeid.toString());
    var result=json.decode(locationResult.body);
    var consolidated_weather=result["consolidated_weather"];
    var data=consolidated_weather[0];

    setState(() {
      temperature=data["the_temp"].round();
      weather=data["weather_state_name"].replaceAll(' ','').toLowerCase();
      abbrevation=data["weather_state_abbr"];
    });
  }

  void onTextFieldSubmitted(input) async {
     await fetchSearch(input);
    await  fetchLocation();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:Container(
        decoration: BoxDecoration(
          image:DecorationImage(
            image:AssetImage('images/$weather.png'),
            fit: BoxFit.cover,
          ),
        ),
        child:temperature==null?Center(child:CircularProgressIndicator())
            :Scaffold(
          backgroundColor: Colors.transparent,
          body:Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                children: [
                Center(
                  child:Image.network('https://www.metaweather.com/static/img/weather/png/64/'+abbrevation+'.png'),
                ),
                  Center(
                    child: Text(
                      temperature.toString() + ' C',
                      style: TextStyle(
                        color:Colors.black,
                        fontSize: 60,
                      ),
                    ),
                  ),
                  Text(
                    location,
                    style: TextStyle(
                      color:Colors.black,
                      fontSize: 40.0,
                    ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Container(
                    width:300.0,
                    child:TextField(
                      onSubmitted: (String input){
                        onTextFieldSubmitted(input);
                      },
                    style:TextStyle(color:Colors.black,fontSize: 25),
                      decoration: InputDecoration(
                        hintText: 'Search for location',
                        hintStyle: TextStyle(color:Colors.white,fontSize: 18.0),
                        prefixIcon: Icon(
                          Icons.search,
                          color:Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:Colors.redAccent,fontSize: Platform.isAndroid?15.0:20.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
