import 'package:bloc_rest_api/bloc_rest_api.dart';
import 'package:blocrestapisample/userdata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

void main() {
  ApiConfig.baseUrl = "https://reqres.in/api/users?page=1";
  ApiConfig.header = {"Content-Type": "application/json"};
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RequestCubit<UserData>(),
        ),
      ],
      child: MaterialApp(
        title: 'Bloc Rest Api',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<RequestCubit<UserData>>().request(fetchdata());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bloc Rest Api'),
      ),
      body: Container(
        child: BlocBuilder<RequestCubit<UserData>, RequestState<UserData>>(
          builder: (context, state) {
            switch (state.status) {
              case RequestStatus.loading:
                return Center(child: CircularProgressIndicator());

              case RequestStatus.success:
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ListView.separated(
                      itemCount: state.model.data.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider(
                          height: 2,
                        );
                      },
                      itemBuilder: (BuildContext context, int index) {
                        Datum d = state.model.data[index];
                        return ListTile(
                          leading: CircleAvatar(),
                          title: Text(
                            d.firstName,
                            style: new TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.0),
                            overflow: TextOverflow.fade,
                          ),
                          subtitle: Text(
                            d.email,
                            style: new TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.0),
                            overflow: TextOverflow.fade,
                          ),
                          trailing: Text(
                            d.id.toString(),
                            style: new TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.0),
                            overflow: TextOverflow.fade,
                          ),
                        );
                      },
                    ),
                  ),
                );

              case RequestStatus.failure:
                return Center(child: Text(state.errorMessage));
              default:
                return Container();
            }
          },
        ),
      ),
    );
  }
}

Future<UserData> fetchdata() async {
  final response = await http.get(ApiConfig.baseUrl);
  if (response.statusCode == 200) {
    return userDataFromJson(response.body);
  } else {
    throw Exception('Failed to load data');
  }
}
