import 'package:flutter/material.dart';

class NavigationBar extends StatelessWidget {
  final bool isActive;
  final Function(bool) setIsActive;
  final List<dynamic> planets;
  final String currentPlanet;

  NavigationBar({
    required this.isActive,
    required this.setIsActive,
    required this.planets,
    required this.currentPlanet,
  });

  void navigateToPlanet(String planetName, BuildContext context) {
    Navigator.pushNamed(context, '/', arguments: {'planet': planetName});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 700),
      transform: Matrix4.translationValues(
        0.0,
        isActive ? 0.0 : -MediaQuery.of(context).size.height,
        0.0,
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => setIsActive(false),
            child: Container(
              width: 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Image.asset('assets/images/menu.png'),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 2.0,
              crossAxisSpacing: 5.0,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                ...planets.map((planet) => GestureDetector(
                  onTap: () {
                    navigateToPlanet(planet['name'], context);
                    setIsActive(false);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 16.0,
                          height: 16.0,
                          child: Image.asset('assets/images/${planet['name']}icon.png'),
                        ),
                        Text(
                          planet['name'],
                          style: TextStyle(
                            color: planet['name'] == currentPlanet
                                ? Colors.white
                                : Colors.grey[400],
                            fontWeight: planet['name'] == currentPlanet
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => print('Open GitHub URL'),
                child: Text('Github', style: TextStyle(decoration: TextDecoration.underline)),
              ),
              Text('Designed and developed by gnpaone'),
            ],
          ),
        ],
      ),
    );
  }
}
