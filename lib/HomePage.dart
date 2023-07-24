import 'package:flutter/material.dart';
import 'package:three_dart/three_dart.dart' as three;
import 'package:three_dart_jsm/three_dart_jsm.dart' as three_jsm;
import 'package:tweener/tweener.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'src/SplashScreen.dart';
import 'src/NavigationBar.dart' as navBar;

const earthSize = 10;
const defaultZoom = 50;

class HomePage extends StatefulWidget {
  final String fileName;
  const HomePage({Key? key, required this.fileName}) : super(key: key);

  @override
  State<HomePage> createState() => _MyAppState();
}

class _MyAppState extends State<HomePage> {
  late FlutterGlPlugin three3dRender;
  three.WebGLRenderer? renderer;

  final planets = [
    {'name': 'mercury', 'size': earthSize / 3, 'positionX': -400, 'texture': 'mercury.jpg', 'zoom': 15},
    {'name': 'venus', 'size': earthSize * 0.944, 'positionX': -200, 'texture': 'venus.jpg'},
    {'name': 'earth', 'size': earthSize, 'positionX': 0, 'texture': 'earth.jpg'},
    {'name': 'mars', 'size': earthSize / 2, 'positionX': 200, 'texture': 'mars.jpg'},
    {'name': 'jupiter', 'size': earthSize * 11, 'positionX': 550, 'texture': 'jupiter.jpg', 'zoom': 400},
    {'name': 'saturn', 'size': 1, 'positionX': 1000, 'texture': 'earth.jpg', 'zoom': 400},
    {'name': 'uranus', 'size': earthSize * 4, 'positionX': 1500, 'texture': 'uranus.jpg', 'zoom': 200},
    {'name': 'neptune', 'size': earthSize * 3, 'positionX': 1800, 'texture': 'neptune.jpg', 'zoom': 200},
  ];

  final planetsArray = [
    'mercury', 'venus', 'earth', 'mars', 'jupiter', 'saturn', 'uranus', 'neptune',
  ];

  String currentPlanet = 'earth';
  bool isActive = false;
  double loading = 0;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late three.Scene scene;
  late three.Camera camera;
  late three.Mesh mesh;

  double dpr = 1.0;

  var amount = 4;

  bool verbose = true;
  bool disposed = false;

  bool loaded = false;

  late three.Object3D object;

  late three.Texture texture;

  late three.WebGLMultisampleRenderTarget renderTarget;

  three.AnimationMixer? mixer;
  three.Clock clock = three.Clock();

  dynamic sourceTexture;

  final GlobalKey<three_jsm.DomLikeListenableState> _globalKey = GlobalKey<three_jsm.DomLikeListenableState>();

  late three_jsm.OrbitControls controls;

  List<Map<String, dynamic>> planetsObjects = [];

  String getNextValue() {
    int currentIndex = planetsArray.indexOf(currentPlanet);
    if (currentIndex < planetsArray.length - 1) {
      return planetsArray[currentIndex + 1];
    } else {
      return currentPlanet;
    }
  }

  String getBackValue() {
    int currentIndex = planetsArray.indexOf(currentPlanet);
    if (currentIndex != 0) {
      return planetsArray[currentIndex - 1];
    } else {
      return currentPlanet;
    }
  }

  void setIsActive(bool isActive) {
    setState(() {
      // Here, you can update any state variables related to isActive if needed
      // For example, you can set isActive as a state variable like this:
      this.isActive = isActive;
    });
  }

  void navigateToPlanet(String planetName) {
    Navigator.pushNamed(context, '/', arguments: {'planet': planetName});
  }

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    width = screenSize!.width;
    height = screenSize!.height;

    three3dRender = FlutterGlPlugin();

    Map<String, dynamic> options = {
      "antialias": true,
      "alpha": false,
      "width": width.toInt(),
      "height": height.toInt(),
      "dpr": dpr
    };

    await three3dRender.initialize(options: options);

    setState(() {});

    // Wait for web
    Future.delayed(const Duration(milliseconds: 100), () async {
      await three3dRender.prepareContext();

      initScene();
    });
  }

  initSize(BuildContext context) {
    if (screenSize != null) {
      return;
    }

    final mqd = MediaQuery.of(context);

    screenSize = mqd.size;
    dpr = mqd.devicePixelRatio;

    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
        appBar: AppBar(
          title: Text(widget.fileName),
        ),
        body: Builder(
          builder: (BuildContext context) {
            initSize(context);
            return SingleChildScrollView(child: _build(context));
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Text("render"),
          onPressed: () {
            clickRender();
          },
        ),
      ),
    );
  }

  Widget _build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            three_jsm.DomLikeListenable(
                key: _globalKey,
                builder: (BuildContext context) {
                  return Container(
                      width: screenSize!.width,
                      height: screenSize!.height,
                      color: Colors.black,
                      child: Builder(builder: (BuildContext context) {
                        if (kIsWeb) {
                          return three3dRender.isInitialized
                              ? HtmlElementView(viewType: three3dRender.textureId!.toString())
                              : Container();
                        } else {
                          return three3dRender.isInitialized
                              ? Texture(textureId: three3dRender.textureId!)
                              : Container();
                        }
                      }));
                }),
          ],
        ),
        // SplashScreen
        SplashScreen(load: loading, light: true),
        // NavigationBar
        navBar.NavigationBar(isActive: isActive, setIsActive: setIsActive, planets: planets, currentPlanet: currentPlanet),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...planets.map((planet) => ElevatedButton(
                    onPressed: () => navigateToPlanet(planet['name'] as String),
                    style: ElevatedButton.styleFrom(
                      primary: planet['name'] == currentPlanet ? Colors.black : Colors.grey[500],
                      padding: const EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: planet['name'] == currentPlanet ? 4 : 0,
                    ),
                    child: Text(planet['name'] as String),
                  )),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => setIsActive(true),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  padding: const EdgeInsets.all(8.0),
                  shape: CircleBorder(),
                ),
                child: Icon(Icons.menu),
              ),
            ],
          ),
        ),
      ],
    );
  }

  clickRender() {
    print(" click render... ");
    animate();
  }

  render() {
    int t = DateTime.now().millisecondsSinceEpoch;

    final gl = three3dRender.gl;

    renderer!.render(scene, camera);

    int t1 = DateTime.now().millisecondsSinceEpoch;

    if (verbose) {
      print("render cost: ${t1 - t} ");
      print(renderer!.info.memory);
      print(renderer!.info.render);
    }

    // 重要 更新纹理之前一定要调用 确保gl程序执行完毕
    gl.flush();

    if (verbose) print(" render: sourceTexture: $sourceTexture ");

    if (!kIsWeb) {
      three3dRender.updateTexture(sourceTexture);
    }
  }

  initRenderer() {
    Map<String, dynamic> options = {
      "width": width,
      "height": height,
      "gl": three3dRender.gl,
      "antialias": false,
      "canvas": three3dRender.element
    };
    renderer = three.WebGLRenderer(options);
    renderer!.setPixelRatio(dpr);
    renderer!.setSize(width, height, false);
    renderer!.shadowMap.enabled = false;

    if (!kIsWeb) {
      var pars = three.WebGLRenderTargetOptions({"minFilter": three.LinearFilter, "magFilter": three.LinearFilter, "format": three.RGBAFormat});
      renderTarget = three.WebGLMultisampleRenderTarget((width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderTarget.samples = 4;
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }
  }

  initScene() {
    initRenderer();
    initPage();
  }

  initPage() async {
    camera = three.PerspectiveCamera(35, width / height, 1, 1000);
    camera.position.setZ(50);

    // scene

    scene = three.Scene();

    var pointLight = three.PointLight(0xffffff);

    pointLight.position.set(-100, 0, 0 );
    scene.add(pointLight);

    controls = three_jsm.OrbitControls(camera, _globalKey);
    controls.enableDamping = true;

    addAllPlanets();

    var earthClouds = await three.TextureLoader(null).loadAsync('assets/images/clouds.jpg', null);
    var earthgeo = three.SphereGeometry(10.1, 32, 32);
    var earthstd = three.MeshStandardMaterial({
      "map": earthClouds,
      "alphaMap": earthClouds,
      "transparent": 1,
    });
    var earthCloudsScene = three.Mesh(earthgeo, earthstd);

    scene.add(earthCloudsScene);

    var result = await three_jsm.GLTFLoader(null).setPath('assets/model/').load('saturn.glb');
    // var result = await loader.loadAsync( 'BoomBox.glb' );
    // var result = await loader.loadAsync('untitled.glb');

    print(" gltf load sucess result: $result  ");

    object = result["scene"];

    object.position.set(1000, 0, 0);
    object.scale.set(0.12, 0.12, 0.12);
    if (object != null) {
      object.rotation.set(0.2, 0, 0);
    }

    scene.add(object);

    for (int i = 0; i < scene.children.length; i++) {
      var potentialPlanet = scene.children[i];
      if (potentialPlanet.name != null) {
        var actualPlanet = potentialPlanet;
        planetsObjects.add({
          'object': actualPlanet,
          'planet': actualPlanet.name,
        });
      }
    }

    // scene.overrideMaterial = new three.MeshBasicMaterial();

    loaded = true;

    animate();

    animated(planetsObjects, earthCloudsScene, object, pointLight);
  }

  animate() {
    if (!mounted || disposed) {
      return;
    }

    if (!loaded) {
      return;
    }

    var delta = clock.getDelta();

    mixer?.update(delta);

    render();

    // Future.delayed(Duration(milliseconds: 40), () {
    //   animate();
    // });
  }

  @override
  void dispose() {
    print(" dispose ............. ");
    disposed = true;
    three3dRender.dispose();

    super.dispose();
  }

  void addAllPlanets() {
    for (final planetData in planets) {
      final planetName = planetData['name'] as String;
      final planetSize = planetData['size'] as double;
      final planetTexture = planetData['texture'] as String;
      final planetPosition = planetData['positionX'] as double;
      final planetZoom = planetData['zoom'] as double? ?? 40;

      newPlanet(planetName, planetSize, planetTexture, planetPosition, planetZoom);
    }
    var defaultLoadingManager = new three.LoadingManager(null, null, null);
    defaultLoadingManager.onStart = onLoadingStart;
    defaultLoadingManager.onProgress = onLoadingProgress;
  }

  void newPlanet(String name, double size, String texture, double positionX, double zoom) async {
    var planetTexture = await three.TextureLoader(null).loadAsync('$texture');
    var spgeo = three.SphereGeometry(size, 32, 32);
    var mstd = three.MeshStandardMaterial({
      "map": planetTexture,
    });
    var planet3D = three.Mesh(spgeo, mstd);
    planet3D.name = name;
    planet3D.scale.set(zoom, zoom, zoom);
    planet3D.position.set(positionX, 0, 0);
    scene.add(planet3D);
  }

  void onLoadingStart(String url, int itemsLoaded, int itemsTotal) {
    loading = itemsLoaded / itemsTotal;
    setState(() {});
  }

  void onLoadingProgress(String url, int itemsLoaded, int itemsTotal) {
    loading = itemsLoaded / itemsTotal;
    setState(() {});
  }

  void updatePositionForCamera(List<Map<String, dynamic>> planetsObjects, double zoom, String searchVal) {
    var object = planetsObjects.firstWhere((obj) => obj['planet'] == searchVal)['object'];
    var oldObject = planetsObjects.firstWhere((obj) => obj['planet'] == 'earth')['object'];

    var from = camera.position.clone();
    oldObject = oldObject ?? object;
    var to = three.Vector3(oldObject.position.x, oldObject.position.y, 800);
    var to2 = three.Vector3(object.position.x, object.position.y, object.zoom);

    var A = new Tweener({
      "x": from.x, "y": from.y, "z": from.z
    }).to({
      "x": to.x, "y": to.y, "z": to.z
    }, 1500).easing(Ease.expo.easeInOut).onUpdate((step) {
      camera.position.set(step["x"], step["y"], step["z"]);
      controls.update();
    }).onComplete(() {
      oldObject = object;
      var from1 = controls.target;
      var to3 = new three.Vector3(object.position.x, 0, 0);
      var tween = new Tweener({
        "x": from1.x, "y": from1.y, "z": from1.z
      }).to({
        "x": to3.x, "y": to3.y, "z": to3.z
      }, 1000).easing(Ease.quad.easeOut);
      tween.start();
      var B = new Tweener({
        "x": from.x, "y": from.y, "z": from.z
      }).to({
        "x": to2.x, "y": to2.y, "z": to2.z
      }, 1500).easing(Ease.cubic.easeInOut).onUpdate((step) {
        camera.position.set(step["x"], step["y"], step["z"]);
        controls.update();
      });
      B.start();
    });
    A.start();
    controls.update();
  }

  void animated(List<Map<String, dynamic>> planetsObjects, three.Mesh earthCloudsScene, three.Object3D saturnmodel, three.PointLight pointLight) {

    // Rotating all planets
    for (final planet in planetsObjects) {
      if (planet['planet'] != null) {
        planet['object'].rotation.x += 0.0000001;
        planet['object'].rotation.y += 0.001;
      }
    }

    // Rotating all planet objects
    earthCloudsScene.rotation.x += 0.0000002;
    earthCloudsScene.rotation.y += 0.002;
    if (saturnmodel != null) {
      saturnmodel!.rotation.y += 0.001;
    }

    // Keeping light position in sync with camera.
    final orbitPosition = controls.object.position;
    pointLight.position.set(orbitPosition.x, orbitPosition.y, orbitPosition.z);

    controls.update();
    render();

    if (!disposed) {
      // Trigger next frame
      Future.delayed(const Duration(milliseconds: 40), () {
        animated(planetsObjects, earthCloudsScene, saturnmodel, pointLight);
      });
    }
  }
}