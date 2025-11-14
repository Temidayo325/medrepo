import 'package:flutter/material.dart';
import 'components/profile_picure.dart';
import 'components/profile_info.dart';

class ProfilePage extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        leading: Icon(Icons.arrow_back, color: Colors.blueGrey.shade800, size: 25,),
        centerTitle: true,
        title: Text('Profile',style: TextStyle(fontSize: 25, color: Colors.blueGrey, fontWeight: FontWeight.bold, decoration: TextDecoration.none,))
      ),
      body: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10,),
              ProfileAvatar(),
              SizedBox(height: 15),
              Text('Opeyemi Temidayo', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800,),),
              SizedBox(height: 15),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10), // inner spacing
                  margin: EdgeInsets.symmetric(horizontal: 15), // outer spacing
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Male, 30 yo', style: TextStyle(fontSize: 17, color: Colors.black, letterSpacing: 1.2 ),),
                      SizedBox(height: 2,),
                      Text('+2347060681466', style: TextStyle(fontSize: 17, color: Colors.black, letterSpacing: 1.2)),
                      Text('temi325@gmail.com', style: TextStyle(fontSize: 17, color: Colors.black)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12), // inner spacing
                  margin: EdgeInsets.symmetric(horizontal: 15), // outer spacing
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('O+, AA, BMI: 25kg', style: TextStyle(fontSize: 17, color: Colors.black, letterSpacing: 1.2 ),),
                      SizedBox(height: 2,),
                      // Text('hgt:160cm, Wgt:55kg', style: TextStyle(fontSize: 14, color: Colors.black, letterSpacing: 1)),
                      Text('Chronic conditions: None', style: TextStyle(fontSize: 17, color: Colors.black)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ProfileInfoCard(
                header: 'Emergency Contact 1',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Opeyemi Gbenga'),
                    SizedBox(height: 8),
                    Text('+2347060681466'),
                    SizedBox(height: 8),
                    Text('temi325@gmail.com'),
                  ],
                ),
              ),
              ProfileInfoCard(
                header: 'Emergency Contact 2',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cyril Fehintoluwa'),
                    SizedBox(height: 8),
                    Text('+2347060681466'),
                    SizedBox(height: 8),
                    Text('temi325@gmail.com'),
                  ],
                ),
              ),
            ],
          ),
        ]
      )
    );
  }
}