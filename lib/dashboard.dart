import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gpstrackingplan/main.dart';
import 'package:gpstrackingplan/routevisiting.dart';
import 'package:gpstrackingplan/saleorder.dart';
import 'package:gpstrackingplan/takeleave.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';
import 'helpers/database_helper.dart';
import 'models/customermodel.dart';

class MyDashboard extends StatefulWidget {
  final List<Customermodel> listCustomers;
  MyDashboard({Key key, this.listCustomers}) : super(key: key);
  @override
  _MyDashboardState createState() => _MyDashboardState(this.listCustomers);
}

class _MyDashboardState extends State<MyDashboard> {
  final List<Customermodel> listCustomers;

  _MyDashboardState(this.listCustomers);

  saveCustomer() async {
    var db = DatabaseHelper();
    var getList = await db.getAllCustomerlocal();
    List<Customermodel> listLocal=[];
    for(var itm in getList){
      Customermodel customermodel = Customermodel.fromMap(itm);
      listLocal.add(customermodel);
    }
    if(listLocal.length > 0){
      print('update');
      var mapLocal = listLocal.map((f)=>f.customerID);
      var mapServer = listCustomers.map((f)=>f.customerID);
      var addList = mapServer.where((x)=>!mapLocal.contains(x)).toList();
      var deleteList = mapLocal.where((x)=>!mapServer.contains(x)).toList();
      for (int i = 0; i < addList.length; i++) {
        var customer = listCustomers.where((x)=>x.customerID == addList[i]).toList();
        db.saveCustomer(customer[0]);
      }
      for (int i = 0; i < deleteList.length; i++) {
        db.deleteCustomer(deleteList[i]);
      }
    }
    else{
      print('add new');
      for (int i = 0; i < listCustomers.length; i++) {
        db.saveCustomer(listCustomers[i]);
      }
    }
  }

  Material myItems(IconData icon, String heading, int color,
      BuildContext context, String page) {
    return Material(
      color: Colors.white,
      elevation: 4.0,
      borderRadius: BorderRadius.circular(20.0),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(heading,
                          style: TextStyle(
                              color: new Color(color), fontSize: 20.0)),
                    ),
                  ),
                  Material(
                    color: new Color(color),
                    borderRadius: BorderRadius.circular(24.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: InkWell(
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        onTap: () async {
                          switch (page) {
                            case 'visit':
                              var db = DatabaseHelper();
                              // List<Customermodel> list = await db.getCustomerlocal();
                              // print('test = $list');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Routevisiting(
                                        //  customerLocal: list,
                                      )));
                              break;
                            case 'leave':
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Takeleave()));
                              break;
                            case 'saleorder':
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SaleOrder()));
                              break;
                            default:
                          }
                        },
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    saveCustomer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        AppLocalizations.of(context).translate('dashboard'),
        style: TextStyle(color: Colors.white),
      )),
      drawer: Drawer(child: MyDrawer()),
      body: StaggeredGridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        children: <Widget>[
          myItems(
              Icons.map,
              AppLocalizations.of(context).translate('route_visit'),
              0xffed622b,
              context,
              'visit'),
          myItems(
              Icons.time_to_leave,
              AppLocalizations.of(context).translate('saleorder'),
              0xffed622b,
              context,
              'saleorder'),
          myItems(
              Icons.time_to_leave,
              AppLocalizations.of(context).translate('take_leave'),
              0xffed622b,
              context,
              'leave'),
        ],
        staggeredTiles: [
          StaggeredTile.extent(2, 150.0),
          StaggeredTile.extent(2, 150.0),
          StaggeredTile.extent(2, 150.0),
        ],
      ),
    );
  }
}

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String _fullName = '';

  _loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = (prefs.getString('fullname') ?? '');
    });
  }

  _removeAppSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.remove('fullname');
      prefs.remove('linkedCustomerID');
      prefs.remove('Id');
      prefs.remove('deleteItems');
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSetting();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Image.asset('assets/images/user.png'),
                  radius: 50.0,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _fullName,
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ),
              )
            ],
          ),
          padding: EdgeInsets.only(top: 35.0, left: 20.0),
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
        ),
        ListTile(
          title: Text(AppLocalizations.of(context).translate('route_visit')),
          leading: Icon(Icons.map),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => Routevisiting()));
          },
        ),
        ListTile(
          title: Text(AppLocalizations.of(context).translate('take_leave')),
          leading: Icon(Icons.time_to_leave),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Takeleave()));
          },
        ),
        ListTile(
          title: Text(AppLocalizations.of(context).translate('saleorder')),
          leading: Icon(Icons.time_to_leave),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => SaleOrder()));
          },
        ),
        ListTile(
          title: Text(AppLocalizations.of(context).translate('logout')),
          leading: Icon(Icons.backspace),
          onTap: () {
            _removeAppSetting();
            Navigator.of(context).pop();
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MyHomePage()));
          },
        ),
      ],
    );
  }
}
