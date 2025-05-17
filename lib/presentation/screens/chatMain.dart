import 'package:flutter/material.dart';
import 'package:flutter_application_4_geodesica/presentation/providers/messageProvider.dart';
import 'package:flutter_application_4_geodesica/presentation/providers/themeProvider.dart';
import 'package:flutter_application_4_geodesica/presentation/providers/userProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_4_geodesica/model/user_message_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  bool _isProcessing = false;
  List<Sphere3DPoint> spherePoints = [];

  // Controladores de animación
  late AnimationController _logoAnimationController;
  late Animation<double> _rotateYAnimation;
  late AnimationController _particleAnimationController;
  late AnimationController _messageAnimationController;

  // Lista para las animaciones de mensajes
  final List<MessageAnimationState> _messageAnimations = [];

  // Para efectos de partículas al enviar mensajes
  final List<ParticleEffect> _particleEffects = [];

  // Colores de la paleta extendida (los mismos que en AuthScreen)
  final Color mainGreenColor = Color(0xFF59A897);
  final Color darkGreenColor = Color(0xFF1D413E);
  final Color brightGreenColor = Color(0xFF46E0C9);
  final Color lightGreenColor = Color(0xFF7DECD0);
  final Color pureWhite = Colors.white;
  final Color offWhite = Color(0xFFF8F8F8);
  final Color pearlWhite = Color(0xFFE6EEF0);
  final Color backgroundBlack = Colors.black;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Inicializar la geodésica y las animaciones
    _generateGeodesicPoints();

    // Controlador para la animación del logo (continua)
    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // Controlador para las animaciones de partículas
    _particleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Controlador para las animaciones de mensajes
    _messageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Animación de rotación (solo en el eje Y para mantener sensación 3D)
    _rotateYAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _logoAnimationController, curve: Curves.linear),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMessages();
    });
  }

  // Método para generar puntos de la geodésica en 3D
  void _generateGeodesicPoints() {
    spherePoints = [];
    // Subdivisiones para la geodésica
    int frequency = 1; // Menos subdivisiones para un rendimiento más ligero
    double radius = 20; // Radio más pequeño para el header

    // Generar icosaedro base y subdividir
    _generateIcosahedron(radius);

    // Subdividir las caras para crear la geodésica
    for (int i = 0; i < frequency - 1; i++) {
      List<Sphere3DPoint> newPoints = List.from(spherePoints);

      for (int j = 0; j < spherePoints.length; j += 3) {
        if (j + 2 < spherePoints.length) {
          Sphere3DPoint p1 = spherePoints[j];
          Sphere3DPoint p2 = spherePoints[j + 1];
          Sphere3DPoint p3 = spherePoints[j + 2];

          // Crear punto medio entre p1 y p2
          Sphere3DPoint mid1 = Sphere3DPoint(
            (p1.x + p2.x) / 2,
            (p1.y + p2.y) / 2,
            (p1.z + p2.z) / 2,
          );
          mid1.normalize(radius);

          // Crear punto medio entre p2 y p3
          Sphere3DPoint mid2 = Sphere3DPoint(
            (p2.x + p3.x) / 2,
            (p2.y + p3.y) / 2,
            (p2.z + p3.z) / 2,
          );
          mid2.normalize(radius);

          // Crear punto medio entre p3 y p1
          Sphere3DPoint mid3 = Sphere3DPoint(
            (p3.x + p1.x) / 2,
            (p3.y + p1.y) / 2,
            (p3.z + p1.z) / 2,
          );
          mid3.normalize(radius);

          // Añadir los triángulos subdivididos
          newPoints.addAll([p1, mid1, mid3]);
          newPoints.addAll([p2, mid2, mid1]);
          newPoints.addAll([p3, mid3, mid2]);
          newPoints.addAll([mid1, mid2, mid3]);
        }
      }

      spherePoints = newPoints;
    }
  }

  // Generar icosaedro base (poliedro de 20 caras triangulares)
  void _generateIcosahedron(double radius) {
    // Factor para generar los vértices del icosaedro
    double t = (1.0 + math.sqrt(5.0)) / 2.0;

    // Normalizar para que todos los puntos estén a la misma distancia (radio)
    double normalizationFactor = radius / math.sqrt(1 + t * t);

    // Los 12 vértices del icosaedro
    List<Sphere3DPoint> vertices = [
      Sphere3DPoint(-1, t, 0)..normalize(normalizationFactor),
      Sphere3DPoint(1, t, 0)..normalize(normalizationFactor),
      Sphere3DPoint(-1, -t, 0)..normalize(normalizationFactor),
      Sphere3DPoint(1, -t, 0)..normalize(normalizationFactor),

      Sphere3DPoint(0, -1, t)..normalize(normalizationFactor),
      Sphere3DPoint(0, 1, t)..normalize(normalizationFactor),
      Sphere3DPoint(0, -1, -t)..normalize(normalizationFactor),
      Sphere3DPoint(0, 1, -t)..normalize(normalizationFactor),

      Sphere3DPoint(t, 0, -1)..normalize(normalizationFactor),
      Sphere3DPoint(t, 0, 1)..normalize(normalizationFactor),
      Sphere3DPoint(-t, 0, -1)..normalize(normalizationFactor),
      Sphere3DPoint(-t, 0, 1)..normalize(normalizationFactor),
    ];

    // Las 20 caras del icosaedro (definidas por tríadas de vértices)
    List<List<int>> faces = [
      [0, 11, 5],
      [0, 5, 1],
      [0, 1, 7],
      [0, 7, 10],
      [0, 10, 11],
      [1, 5, 9],
      [5, 11, 4],
      [11, 10, 2],
      [10, 7, 6],
      [7, 1, 8],
      [3, 9, 4],
      [3, 4, 2],
      [3, 2, 6],
      [3, 6, 8],
      [3, 8, 9],
      [4, 9, 5],
      [2, 4, 11],
      [6, 2, 10],
      [8, 6, 7],
      [9, 8, 1],
    ];

    // Añadir todos los triángulos a la lista de puntos
    for (List<int> face in faces) {
      spherePoints.add(vertices[face[0]]);
      spherePoints.add(vertices[face[1]]);
      spherePoints.add(vertices[face[2]]);
    }
  }

  Future<void> _loadMessages() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (userProvider.currentChatId != null) {
      await chatProvider.loadInitialMessages(userProvider.currentChatId!);
      // Inicializar estado de animación para mensajes existentes
      for (var _ in chatProvider.messages) {
        _messageAnimations.add(
          MessageAnimationState(
            controller: AnimationController(
              vsync: this,
              duration: const Duration(milliseconds: 300),
            )..forward(),
          ),
        );
      }
    } else {
      // Si no hay chat actual, mostrar un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: No se pudo cargar la conversación'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _particleAnimationController.dispose();
    _messageAnimationController.dispose();

    // Limpiar controladores de animación de mensajes
    for (var animation in _messageAnimations) {
      animation.controller.dispose();
    }

    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _createParticleEffect() {
    final random = math.Random();
    final newEffect = ParticleEffect(
      startPosition: Offset(
        MediaQuery.of(context).size.width - 60,
        MediaQuery.of(context).size.height - 60,
      ),
      particles: List.generate(20, (_) {
        return Particle(
          position: Offset(
            MediaQuery.of(context).size.width - 60,
            MediaQuery.of(context).size.height - 60,
          ),
          velocity: Offset(
            (random.nextDouble() * 2 - 1) * 3,
            (random.nextDouble() * 2 - 1) * 3,
          ),
          color:
              Color.lerp(
                brightGreenColor,
                lightGreenColor,
                random.nextDouble(),
              )!,
          size: random.nextDouble() * 8 + 2,
          lifespan: random.nextDouble() * 0.7 + 0.3,
        );
      }),
    );

    setState(() {
      _particleEffects.add(newEffect);
    });

    _particleAnimationController.reset();
    _particleAnimationController.forward().then((_) {
      setState(() {
        _particleEffects.remove(newEffect);
      });
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isProcessing) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (userProvider.currentChatId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: No hay una conversación activa'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Crear efecto de partículas
    _createParticleEffect();

    // Añadir mensaje del usuario
    final newMessage = UserMessageModel(
      rol: 'user',
      message: userMessage,
      id: DateTime.now().millisecondsSinceEpoch,
    );

    chatProvider.addMessage(newMessage);
    await chatProvider.saveMessageToDatabase(
      userProvider.currentChatId!,
      newMessage,
    );

    // Añadir estado de animación para el nuevo mensaje
    _messageAnimations.add(
      MessageAnimationState(
        controller: AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        )..forward(),
      ),
    );

    // Auto-scroll al último mensaje
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Mostrar que estamos procesando
    setState(() {
      _isProcessing = true;
    });

    try {
      // Procesamiento de la consulta
      String responseText;

      // Verificar si es una consulta de contabilidad
      if (userMessage.toLowerCase().contains('contabilidad') ||
          userMessage.toLowerCase().contains('finanzas') ||
          userMessage.toLowerCase().contains('gastos') ||
          userMessage.toLowerCase().contains('ingresos')) {
        responseText = await chatProvider.processAccountingQuery(userMessage);
      } else {
        // Respuesta genérica
        responseText =
            'Gracias por tu mensaje. Para consultas sobre contabilidad, puedes preguntar sobre ingresos, gastos, balance o transacciones recientes.';
      }

      // Agregar la respuesta del sistema
      final responseMessage = UserMessageModel(
        rol: 'system',
        message: responseText,
        id: DateTime.now().millisecondsSinceEpoch + 1,
      );

      chatProvider.addMessage(responseMessage);
      await chatProvider.saveMessageToDatabase(
        userProvider.currentChatId!,
        responseMessage,
      );

      // Añadir estado de animación para la respuesta
      _messageAnimations.add(
        MessageAnimationState(
          controller: AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 300),
          )..forward(),
        ),
      );

      // Auto-scroll al último mensaje de respuesta
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      // En caso de error, mostrar mensaje
      final errorMessage = UserMessageModel(
        rol: 'system',
        message: 'Lo siento, ocurrió un error al procesar tu mensaje.',
        id: DateTime.now().millisecondsSinceEpoch + 1,
      );

      chatProvider.addMessage(errorMessage);
      await chatProvider.saveMessageToDatabase(
        userProvider.currentChatId!,
        errorMessage,
      );

      // Añadir estado de animación para el mensaje de error
      _messageAnimations.add(
        MessageAnimationState(
          controller: AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 300),
          )..forward(),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _logout() {
    // Limpiar el provider
    Provider.of<UserProvider>(context, listen: false).logout();
    Provider.of<ChatProvider>(context, listen: false).clearMessages();

    // Navegar a la pantalla de inicio de sesión
    Navigator.of(context).pushReplacementNamed('/');
  }

  // Widget para dibujar la geodésica 3D con rotación en el AppBar
  Widget _buildGeodesicaLogo() {
    return AnimatedBuilder(
      animation: _logoAnimationController,
      builder: (context, child) {
        return Container(
          width: 36,
          height: 36,
          child: CustomPaint(
            size: Size(36, 36),
            painter: Geodesic3DPainter(
              mainColor: mainGreenColor,
              accentColor: brightGreenColor,
              highlightColor: pureWhite,
              spherePoints: spherePoints,
              rotationY: _rotateYAnimation.value,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<AppThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor:
            isDarkMode
                ? Color.lerp(backgroundBlack, darkGreenColor, 0.3)
                : Color.lerp(mainGreenColor, pureWhite, 0.85),
        elevation: 0,
        title: Row(
          children: [
            _buildGeodesicaLogo(),
            SizedBox(width: 10),
            ShaderMask(
              shaderCallback:
                  (bounds) => LinearGradient(
                    colors: [
                      mainGreenColor,
                      brightGreenColor,
                      pureWhite,
                      lightGreenColor,
                    ],
                    stops: [0.0, 0.4, 0.6, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
              child: Text(
                'Geodesica',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.settings,
              color: isDarkMode ? pureWhite : darkGreenColor,
            ),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'theme',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tema'),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Claro'),
                            selected: !themeProvider.isDarkMode,
                            selectedColor: brightGreenColor.withOpacity(0.7),
                            onSelected: (selected) {
                              if (selected) {
                                themeProvider.setThemeMode(false);
                              }
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Oscuro'),
                            selected: themeProvider.isDarkMode,
                            selectedColor: brightGreenColor.withOpacity(0.7),
                            onSelected: (selected) {
                              if (selected) {
                                themeProvider.setThemeMode(true);
                              }
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'fontSize',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tamaño de letra'),
                      Slider(
                        value: themeProvider.fontSize,
                        min: 12.0,
                        max: 24.0,
                        divisions: 4,
                        activeColor: brightGreenColor,
                        label: themeProvider.fontSize.round().toString(),
                        onChanged: (value) {
                          themeProvider.setFontSize(value);
                        },
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Cerrar sesión',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isDarkMode
                    ? [
                      backgroundBlack,
                      Color.lerp(backgroundBlack, darkGreenColor, 0.2)!,
                    ]
                    : [
                      Color.lerp(pureWhite, mainGreenColor, 0.1)!,
                      Color.lerp(pureWhite, lightGreenColor, 0.2)!,
                    ],
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(child: _buildMessagesList()),
                _buildMessageInput(),
              ],
            ),
            // Capa para dibujar los efectos de partículas
            if (_particleEffects.isNotEmpty)
              Positioned.fill(
                child: CustomPaint(
                  painter: ParticlesPainter(
                    particleEffects: _particleEffects,
                    animation: _particleAnimationController,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    final themeProvider = Provider.of<AppThemeProvider>(context, listen: true);
    final isDarkMode = themeProvider.isDarkMode;

    return Consumer<ChatProvider>(
      builder: (context, provider, child) {
        if (provider.messages.isEmpty) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color:
                    isDarkMode
                        ? darkGreenColor.withOpacity(0.2)
                        : pureWhite.withOpacity(0.7),
                border: Border.all(
                  color: brightGreenColor.withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: brightGreenColor.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          brightGreenColor.withOpacity(0.7),
                          mainGreenColor.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: brightGreenColor.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline,
                      color: pureWhite,
                      size: 30,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'No hay mensajes',
                    style: GoogleFonts.montserrat(
                      fontSize: themeProvider.fontSize + 2,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? pureWhite : darkGreenColor,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '¡Comienza una conversación!',
                    style: GoogleFonts.openSans(
                      fontSize: themeProvider.fontSize,
                      color:
                          isDarkMode
                              ? offWhite.withOpacity(0.8)
                              : darkGreenColor.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          reverse: false,
          itemCount: provider.messages.length,
          itemBuilder: (context, index) {
            final message = provider.messages[index];

            // Asegurar que hay un controlador de animación para este mensaje
            if (index >= _messageAnimations.length) {
              _messageAnimations.add(
                MessageAnimationState(
                  controller: AnimationController(
                    vsync: this,
                    duration: const Duration(milliseconds: 300),
                  )..forward(),
                ),
              );
            }

            return _buildMessageBubble(
              message,
              themeProvider.fontSize,
              _messageAnimations[index].controller,
              index,
            );
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(
    UserMessageModel message,
    double fontSize,
    AnimationController controller,
    int index,
  ) {
    final isUserMessage = message.rol == 'user';
    final isDarkMode = Provider.of<AppThemeProvider>(context).isDarkMode;

    // Construir la animación para este mensaje
    final slideAnimation = Tween<Offset>(
      begin: Offset(isUserMessage ? 1.0 : -1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutQuad));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isUserMessage) _buildAvatarForSystem(),
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            isUserMessage
                                ? [brightGreenColor, mainGreenColor]
                                : isDarkMode
                                ? [
                                  Color.lerp(darkGreenColor, pureWhite, 0.1)!,
                                  Color.lerp(darkGreenColor, pureWhite, 0.2)!,
                                ]
                                : [
                                  pureWhite.withOpacity(0.9),
                                  pearlWhite.withOpacity(0.95),
                                ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20).copyWith(
                        bottomLeft:
                            isUserMessage
                                ? Radius.circular(20)
                                : Radius.circular(5),
                        bottomRight:
                            isUserMessage
                                ? Radius.circular(5)
                                : Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              isUserMessage
                                  ? brightGreenColor.withOpacity(0.3)
                                  : isDarkMode
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color:
                            isUserMessage
                                ? brightGreenColor.withOpacity(0.3)
                                : isDarkMode
                                ? pureWhite.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      message.message,
                      style: GoogleFonts.openSans(
                        color:
                            isUserMessage
                                ? pureWhite
                                : isDarkMode
                                ? pureWhite
                                : darkGreenColor,
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                ),
                if (isUserMessage) SizedBox(width: 8),
                if (isUserMessage)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [brightGreenColor, mainGreenColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: brightGreenColor.withOpacity(0.3),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(Icons.person, color: pureWhite, size: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarForSystem() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              darkGreenColor,
              Color.lerp(darkGreenColor, mainGreenColor, 0.5)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: darkGreenColor.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(child: Icon(Icons.smart_toy, color: pureWhite, size: 16)),
      ),
    );
  }

  Widget _buildMessageInput() {
    final isDarkMode = Provider.of<AppThemeProvider>(context).isDarkMode;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Color.lerp(backgroundBlack, darkGreenColor, 0.15)
                : pureWhite.withOpacity(0.9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color:
                isDarkMode
                    ? Colors.black.withOpacity(0.5)
                    : Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? Color.lerp(backgroundBlack, darkGreenColor, 0.3)
                        : offWhite,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: brightGreenColor.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  hintStyle: GoogleFonts.openSans(
                    color:
                        isDarkMode
                            ? pureWhite.withOpacity(0.6)
                            : darkGreenColor.withOpacity(0.6),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: GoogleFonts.openSans(
                  color: isDarkMode ? pureWhite : darkGreenColor,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [brightGreenColor, mainGreenColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: brightGreenColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child:
                  _isProcessing
                      ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(pureWhite),
                        ),
                      )
                      : Icon(Icons.send_rounded, color: pureWhite, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

// Clase para representar un punto 3D en la esfera
class Sphere3DPoint {
  double x, y, z;

  Sphere3DPoint(this.x, this.y, this.z);

  void normalize(double length) {
    double norm = math.sqrt(x * x + y * y + z * z);
    if (norm > 0) {
      x = (x / norm) * length;
      y = (y / norm) * length;
      z = (z / norm) * length;
    }
  }

  // Aplica rotación en el eje Y
  Sphere3DPoint rotateY(double angle) {
    double newX = x * math.cos(angle) + z * math.sin(angle);
    double newZ = -x * math.sin(angle) + z * math.cos(angle);
    return Sphere3DPoint(newX, y, newZ);
  }

  // Proyección en 2D (perspectiva simple)
  Offset project(double viewDistance) {
    double factor = viewDistance / (viewDistance + z);
    return Offset(x * factor, y * factor);
  }
}

// Clase para manejar el estado de animación de los mensajes
class MessageAnimationState {
  final AnimationController controller;

  MessageAnimationState({required this.controller});
}

// Clase para representar una partícula en el efecto visual
class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double lifespan; // Valor entre 0.0 y 1.0

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.lifespan,
  });
}

// Clase para agrupar partículas en un efecto
class ParticleEffect {
  final Offset startPosition;
  final List<Particle> particles;

  ParticleEffect({required this.startPosition, required this.particles});
}

// Pintor personalizado para la geodésica 3D
class Geodesic3DPainter extends CustomPainter {
  final Color mainColor;
  final Color accentColor;
  final Color highlightColor;
  final List<Sphere3DPoint> spherePoints;
  final double rotationY;

  Geodesic3DPainter({
    required this.mainColor,
    required this.accentColor,
    required this.highlightColor,
    required this.spherePoints,
    required this.rotationY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const viewDistance = 100.0;

    // Pintamos los triángulos de la geodésica
    for (int i = 0; i < spherePoints.length; i += 3) {
      if (i + 2 < spherePoints.length) {
        // Rotamos los puntos
        final p1 = spherePoints[i].rotateY(rotationY);
        final p2 = spherePoints[i + 1].rotateY(rotationY);
        final p3 = spherePoints[i + 2].rotateY(rotationY);

        // Solo dibujamos las caras visibles (Z positiva)
        if (p1.z + p2.z + p3.z > 0) {
          // Proyectamos a 2D
          final point1 = p1.project(viewDistance);
          final point2 = p2.project(viewDistance);
          final point3 = p3.project(viewDistance);

          // Aplicamos el centro
          final screenPoint1 = Offset(
            center.dx + point1.dx,
            center.dy + point1.dy,
          );
          final screenPoint2 = Offset(
            center.dx + point2.dx,
            center.dy + point2.dy,
          );
          final screenPoint3 = Offset(
            center.dx + point3.dx,
            center.dy + point3.dy,
          );

          // Calculamos un valor de iluminación basado en la posición Z
          final avgZ = (p1.z + p2.z + p3.z) / 3;
          final normalizedZ = (avgZ + 20) / 40; // Normalizar entre 0 y 1

          // Gradiente para el color del triángulo
          final paint =
              Paint()
                ..shader = LinearGradient(
                  colors: [
                    Color.lerp(mainColor, accentColor, normalizedZ)!,
                    Color.lerp(accentColor, highlightColor, normalizedZ * 0.5)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(Rect.fromPoints(screenPoint1, screenPoint3))
                ..style = PaintingStyle.fill;

          // Dibujar el triángulo
          final path =
              Path()
                ..moveTo(screenPoint1.dx, screenPoint1.dy)
                ..lineTo(screenPoint2.dx, screenPoint2.dy)
                ..lineTo(screenPoint3.dx, screenPoint3.dy)
                ..close();

          canvas.drawPath(path, paint);

          // Dibujar el borde
          final strokePaint =
              Paint()
                ..color = highlightColor.withOpacity(0.3)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 0.5;

          canvas.drawPath(path, strokePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant Geodesic3DPainter oldDelegate) {
    return oldDelegate.rotationY != rotationY;
  }
}

// Pintor personalizado para el efecto de partículas
class ParticlesPainter extends CustomPainter {
  final List<ParticleEffect> particleEffects;
  final AnimationController animation;

  ParticlesPainter({required this.particleEffects, required this.animation})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (var effect in particleEffects) {
      for (var particle in effect.particles) {
        // Actualizar posición
        particle.position = Offset(
          particle.position.dx + particle.velocity.dx,
          particle.position.dy + particle.velocity.dy,
        );

        // Aplicar un poco de gravedad
        particle.velocity = Offset(
          particle.velocity.dx * 0.98,
          particle.velocity.dy * 0.98 + 0.1,
        );

        // Calcular opacidad basada en el ciclo de vida y la animación
        final opacity = (1.0 - animation.value) * particle.lifespan;

        // Pintar la partícula
        final paint =
            Paint()
              ..color = particle.color.withOpacity(opacity)
              ..style = PaintingStyle.fill
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2);

        canvas.drawCircle(
          particle.position,
          particle.size * (1.0 - animation.value * 0.5),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant ParticlesPainter oldDelegate) {
    return true;
  }
}
