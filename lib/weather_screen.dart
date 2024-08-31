import 'dart:convert';
import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
//import 'package:workstation1/secrets.dart';
import './hourly_forecast_item.dart';
import './additional_info.dart';
import './secrets.dart';
//import './hourly_forecast_item.dart';

import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      // setState(() {
      //   isLoading = true;
      // });
      String cityName = 'Rajpura';

      final res = await http.get(
        Uri.parse(
            
            "https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey")
      );

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'An unexpected error occurred';
      }

      return data;
      // data['list'][0]['main']['temp'];
      // setState(() {
      //   temp = data['main']['temp'];
      //   isLoading = false;
      // });
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              }); // refresh the weather data
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
         // print(snapshot);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;

          final currentWeatherData = data['list'][0];

          final currentTemp = currentWeatherData['main']['temp'];
          final currentSky = currentWeatherData['weather'][0]['main'];

          final currentPressure = currentWeatherData['main']['pressure'];
          final currentWindSpeed = currentWeatherData['wind']['speed'];
          final currentHumidity = currentWeatherData['main']['humidity'];

          // print(snapshot.runtimeType);
          return Padding(
            // child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 10,
                          sigmaY: 10,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$currentTemp K',
                                style: const TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              Icon(
                                currentSky == 'Clouds' || currentSky == 'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 64,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                currentSky,
                                style: const TextStyle(fontSize: 20),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                // Weather forecast card
                const Text(
                  'Hourly Forecast',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       for (int i = 0; i < 38;i++)
                //         HourlyForcastItem(
                //             time: data['list'][i+1]['dt'].toString(),
                //             icon: data['list'][i+1]['weather'][0]['main']== 'Clouds '||
                //               data['list'][i+1]['weather'][0]['main'] ==
                //               'Rain'
                //               ? Icons.cloud
                //               :Icons.sunny,
                //             temperature: data['list'][i+1]['main']['temp'].toString(),
                //           ),
                //       // HourlyForcastItem(
                //       //     time: '03:00',
                //       //     icon: Icons.sunny,
                //       //     temperature: '300.21'),
                //       // HourlyForcastItem(
                //       //     time: '06:00',
                //       //     icon: Icons.cloud,
                //       //     temperature: '301.21'),
                //       // HourlyForcastItem(
                //       //     time: '09:00',
                //       //     icon: Icons.sunny,
                //       //     temperature: '301.21'),
                //       // HourlyForcastItem(
                //       //     time: '12:00',
                //       //     icon: Icons.cloud,
                //       //     temperature: '300.21'),
                //       // HourlyForcastItem(
                //       //     time: '15:00',
                //       //     icon: Icons.sunny,
                //       //     temperature: '300.21'),
                //     ],
                //   ),
                // ),

                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    itemCount: 5,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final hourlyForecast = data['list'][index + 1];
                      final hourlySky =
                          data['list'][index + 1]['weather'][0]['main'];
                      final hourlyTemp =
                          hourlyForecast['main']['temp'].toString();
                      final time = DateTime.parse(hourlyForecast['dt_txt']);
                      return HourlyForcastItem(
                        time: DateFormat.Hm().format(time),
                        temperature: hourlyTemp,
                        icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                            ? Icons.cloud
                            : Icons.sunny,

                        // icon: data['list'][i + 1]['weather'][0]['main'] ==
                        //             'Clouds ' ||
                        //         data['list'][i + 1]['weather'][0]['main'] ==
                        //             'Rain'
                      );
                    },
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                const Text(
                  'Additional Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    //-----------card1----------
                    AdditionalInfo(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: currentHumidity.toString(),
                    ),

                    //----------------card2-------------
                    AdditionalInfo(
                      icon: Icons.air,
                      label: 'Wind Speed',
                      value: currentWindSpeed.toString(),
                    ),
                    //----------------------card3------------
                    AdditionalInfo(
                      icon: Icons.beach_access,
                      label: 'Pressure',
                      value: currentPressure.toString(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}




// import 'dart:convert';
// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// import 'Secrets.dart';
// import 'additional_info.dart';
// import 'hourly_forecast_item.dart';
// import 'package:http/http.dart' as http;
// //import 'package:intl/src/intl/date_format.dart';




// class WeatherScreen extends StatefulWidget {
//   const WeatherScreen({super.key});

//   @override
//   State<WeatherScreen> createState() => _WeatherScreenState();
// }

// class _WeatherScreenState extends State<WeatherScreen> {
//   late Future<Map<String,dynamic>> weather;
//   Future<Map<String, dynamic>> getCurrentWeather() async{

//     try{

//     String cityName = 'Bokaro';

//    final res = await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey')
//      );

//    final data = jsonDecode(res.body);

//    if(data['cod']!= '200'){
//      throw 'an unexpected error occurred';
//    }
//    return data;
//      //temp =(data['list'][0]['main']['temp']);

//     }catch(e){
//       throw e.toString();
//     }
//   }

//   @override
//   void initState() {
    
//     super.initState();
//     weather = getCurrentWeather();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Weather App',
//           style: TextStyle(fontSize: 24, ),
//         ),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             onPressed: () {
//               setState(() {
//                 weather = getCurrentWeather();
//               });
//             },
//             icon: const Icon(Icons.refresh),
//           )
//         ],
//       ),
//       body:FutureBuilder(
//         future: weather,
//         builder:(context, snapshot) {
//           if(snapshot.connectionState == ConnectionState.waiting){
//             return const Center(child:CircularProgressIndicator.adaptive());
//           }
//           if(snapshot.hasError){
//             return  Center(child: Text(snapshot.error.toString()));
//           }

//           final data= snapshot.data!;

//           final currentWeatherData = data['list'][0];

//           final currentTemp =currentWeatherData['main']['temp'];

//           final currentSky = currentWeatherData['weather'][0]['main'];
//           final currentPressure = currentWeatherData['main']['pressure'];
//           final currentWindSpeed = currentWeatherData['wind']['speed'];
//           final currentHumidity = currentWeatherData['main']['humidity'];

//           return Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Main Card
//               SizedBox(
//                 width: double.infinity,
//                 child: Card(
//                   // color:const Color.fromRGBO(47, 50, 71, 1.0),
//                   elevation: 10,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(16),
//                     child: BackdropFilter(
//                       filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                       child:  Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           children: [
//                             Text(
//                               '$currentTemp k',
//                               style: const TextStyle(
//                                 fontSize: 32,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 16,
//                             ),
//                             Icon(
//                               currentSky == 'Cloud' || currentSky == 'Rain' ? Icons.cloud : Icons.sunny,
//                               size: 72,
//                             ),
//                             const SizedBox(
//                               height: 16,
//                             ),
//                             Text(
//                               currentSky,
//                               style:const  TextStyle(
//                                 fontSize: 24,
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Hourly Forecast',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               //Weather forecast Cards

//               const SizedBox(height: 8),
//               //  SingleChildScrollView(
//               //   scrollDirection: Axis.horizontal,
//               //   child: Row(
//               //     children: [
//               //       for(int i=0;i<10;i++)
//               //       //--------------------------------------------Card 1 ---------------------------------------
//               //       HourlyForecastItem(
//               //         time: data['list'][i+1]['dt'].toString()  ,
//               //         icon:data['list'][i+1]['weather'][0]['main']== 'Clouds' || data['list'][i+1]['weather'][0]['main'] == 'Rains' ?Icons.cloud: Icons.sunny,
//               //         temperature: data['list'][i+1]['main']['temp'].toString(),
//               //       ),
//               //     ],
//               //   ),
//               // ),
//               SizedBox(
//                 height: 120,
//                 child: ListView.builder(
//                   itemCount:8 ,
//                   scrollDirection: Axis.horizontal,
//                   itemBuilder:(context,index){
//                     final hourlyForecast = data['list'][index+1];
//                     final hourlySky = data['list'][index+1]['weather'][0]['main'];
//                     final hourlyTemp = hourlyForecast['main']['temp'].toString();
//                     final time = DateTime.parse(hourlyForecast['dt_txt']);

//                     return HourlyForecastItem(
//                     time: DateFormat.Hm().format(time),
//                         temperature: hourlyTemp,
//                         icon:hourlySky == 'Clouds' || hourlySky == 'Rains' ?Icons.cloud: Icons.sunny);
//                   },
//                 ),
//               ),

//               const SizedBox(
//                 height: 20,
//               ),
//               //Additional information
//               const Text('Additional Information',style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),),

//               const SizedBox(height: 8,),
//                Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     //--------------------------------------------Card 1 ---------------------------------------
//                     AdditionalInfo(
//                       icon: Icons.water_drop,
//                       label:"Humidity" ,
//                       value: currentHumidity.toString(),
//                     ),
//                     //----------------------------------------------Card 2 ----------------------------------------
//                     AdditionalInfo(
//                       icon: Icons.air,
//                       label:"Wind Speed" ,
//                       value: currentWindSpeed.toString() ,
//                     ),
//                     //-----------------------------------------Card 3--------------------------------------
//                     AdditionalInfo(
//                       icon: Icons.beach_access,
//                       label:"Pressure" ,
//                       value: currentPressure.toString(),
//                     ),

//                   ],
//                 ),
//             ],
//           ),
//         );
//         },
//       ),
//     );
//   }
// }


