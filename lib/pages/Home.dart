import 'package:flutter/material.dart';
import 'package:mywallet/models/payment.dart';

// class Home extends StatelessWidget {
//   final Payment payment = Payment(name: 'John Doe', description: 'rice');

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.home,
//               size: 100,
//               color: Colors.blue,
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Welcome to Home Screen This is Home.dart',
//               style: TextStyle(fontSize: 20),
//             ),
//             SizedBox(height: 20),
//             _buildPayment(payment),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPayment(Payment payment) {
//     return Column(
//       children: [
//         Text(
//           'User Data:',
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         SizedBox(height: 10),
//         Text('name: ${payment.name}'),
//         Text('description: ${payment.description}'),
//       ],
//     );
//   }
// }

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<Payment> userDataFuture;

  @override
  void initState() {
    super.initState();
    userDataFuture = fetchData(); // Implement your data fetching logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Payment>(
        future: userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home,
                    size: 100,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Welcome to Home Screen This is Home.dart',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  _buildUserData(snapshot.data!),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildUserData(Payment payment) {
    return Column(
      children: [
        Text(
          'User Data:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text('name: ${payment.name}'),
        Text('description: ${payment.description}'),
      ],
    );
  }

  Future<Payment> fetchData() async {
    // Implement your data fetching logic here
    // For example, you might use Dio, http package, or another method
    // to fetch data from an API or a database
    await Future.delayed(Duration(seconds: 2)); // Simulating a delay
    return Payment(name: 'John Doe', description: 'rice');
  }
}
