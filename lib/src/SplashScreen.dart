import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final double load;
  final bool light;

  SplashScreen({required this.load, required this.light});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  List<Map<String, String>> spaceFax = [
    {
      'title': 'A FULL NASA SPACE SUIT COSTS \$12,000,000.',
      'details':
      'While the entire suit costs a cool \$12m, 70% of that cost is for the backpack and control module. However, the space suits that NASA uses were built in 1974.'
    },
    {
      'title': 'THERE IS A PLANET MADE OF DIAMONDS',
      'details':
      'There’s a planet made of diamonds twice the size of earth. The "super earth," aka 55 Cancri e, is most likely covered in graphite and diamond.'
    },
    {
      'title': 'THE SUNSET ON MARS APPEARS BLUE',
      'details':
      'Just as colors are made more dramatic in sunsets on Earth, sunsets on Mars, according to NASA, would appear bluish to human observers watching from the red planet.'
    },
    {
      'title': 'ONE DAY ON VENUS IS LONGER THAN ONE YEAR.',
      'details':
      'Venus has a slow axis rotation which takes 243 Earth days to complete its day. The orbit of Venus around the Sun is 225 Earth days.'
    },
    {
      'title': 'THE HOTTEST PLANET IN OUR SOLAR SYSTEM IS 450° C.',
      'details':
      'Venus; even though is not the closest planet to the sun is the hottest planet in the solar system and has an average surface temperature of around 450° C.'
    },
  ];

  int randomNum = -1;

  @override
  void initState() {
    super.initState();
    randomNum = generateRandomNumber();
  }

  int generateRandomNumber() {
    return (widget.load == 1) ? -1 : (widget.load * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key('splashScreenScaffold'), // Add a unique key
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,// Set the height to a specific value
          child: AnimatedOpacity(
            opacity: (randomNum == -1) ? 0.0 : 1.0,
            duration: Duration(milliseconds: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  value: widget.load,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.light ? Colors.white : Colors.black,
                  ),
                  strokeWidth: 4.0,
                ),
                SizedBox(height: 10.0),
                Text(
                  'Loading: ${randomNum == -1 ? 0 : randomNum}%',
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
                if (randomNum != -1)
                  Container(
                    width: 180,
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      children: [
                        Text(
                          'DID YOU KNOW',
                          style: TextStyle(fontSize: 12.0, color: Colors.white),
                        ),
                        SizedBox(height: 5.0),
                        Flexible(
                          child: Text(
                            randomNum >= 0
                                ? spaceFax[randomNum % spaceFax.length]['title'] ??
                                ''
                                : '',
                            style:
                            TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Flexible(
                          child: Text(
                            randomNum >= 0
                                ? spaceFax[randomNum % spaceFax.length]['details'] ??
                                ''
                                : '',
                            style:
                            TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
