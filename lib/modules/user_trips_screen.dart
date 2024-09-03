import 'package:flutter/material.dart';

class UserTripsScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width -124;
    final trueScreenWidth = (MediaQuery.of(context).size.width-124)/4;

    return Container(
      width: double.infinity,
      color: Colors.grey[700],
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 50,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                SizedBox(
                  width: screenWidth / 4,
                  child: const Text('ID',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    height: double.infinity,
                    width: 2,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  width: screenWidth / 4,
                  child: const Text('Name',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    height: double.infinity,
                    width: 2,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  width: screenWidth / 4,
                  child: const Text('Phone Number',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    height: double.infinity,
                    width: 2,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  width: screenWidth / 4,
                  child: const Text('App Version',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              width: double.infinity,
              height: 70,
              decoration:  BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Container(width: trueScreenWidth, child: Text('10314')),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      height: double.infinity,
                      width: 2,
                      color: Colors.grey,
                    ),
                  ),
                  Container(width: trueScreenWidth, child: Text('10314')),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      height: double.infinity,
                      width: 2,
                      color: Colors.grey,
                    ),
                  ),
                  Container(width: trueScreenWidth, child: Text('10314')),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      height: double.infinity,
                      width: 2,
                      color: Colors.grey,
                    ),
                  ),
                  Container(width: trueScreenWidth, child: Text('10314')),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
