import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gpstrackingplan/main.dart';
import 'package:gpstrackingplan/routevisit.dart';
import 'package:gpstrackingplan/takeleave.dart';

class Dashboard extends StatelessWidget {

 Material myItems(IconData icon,String heading,int color,BuildContext context,String page){
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
                     child: Text(
                       heading,
                       style:TextStyle(
                         color: new Color(color),
                         fontSize: 20.0
                       )
                     ),
                   ),
                 ),
                Material(
                  color: new Color(color),
                  borderRadius: BorderRadius.circular(24.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: InkWell(
                      child:Icon(
                        icon,
                        color: Colors.white,
                        size: 30.0,
                      ),
                      onTap: (){
                        print('Click menu');
                        switch (page) {
                          case 'visit':
                            Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) => Routevisit()));
                            break;
                          case 'leave':
                            Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) => Takeleave()));
                            break;
                          default:
                        }
                        // Navigator.push(
                        //           context, 
                        //           MaterialPageRoute(builder: (context) => MyHomePage()));
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white
          ),
        ) 
      ),
      body: StaggeredGridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        padding: EdgeInsets.symmetric(vertical: 16.0,horizontal: 8.0),
        children: <Widget>[
          myItems(Icons.map, "Route Visit", 0xffed622b,context,'visit'),
          myItems(Icons.graphic_eq, "Feedback", 0xffed622b,context,'feedback'),
          myItems(Icons.time_to_leave, "Take Leave", 0xffed622b,context,'leave')
        ],
        staggeredTiles: [
          StaggeredTile.extent(1, 130.0),
          StaggeredTile.extent(1, 130.0),
          StaggeredTile.extent(2, 130.0)
        ],
      ),
    );
  }
}