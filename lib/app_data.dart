import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'constants.dart';
import 'drawable.dart';

// Modelos usados para streaming, function-calling y reparación de JSON.
const streamingModel = 'granite4:3b';
const functionCallingModel = 'granite4:3b';
const jsonFixModel = 'granite4:3b';

// Estado global de la app: dibujo, selección, llamadas al modelo y utilidades.
class AppData extends ChangeNotifier {
  // Texto acumulado de respuestas del modelo.
  String _responseText = "";
  // Estado de carga y estado inicial de la UI.
  bool _isLoading = false;
  bool _isInitial = true;

  // Clientes HTTP para peticiones normales y streaming cancelable.
  http.Client? _client;
  IOClient? _ioClient;
  HttpClient? _httpClient;
  StreamSubscription<String>? _streamSubscription;

  // Índice de la forma seleccionada actualmente.
  int? _selectedShapeIndex;

  // Tamaño actual del canvas (información enviada al modelo).
  double canvasWidth = 0;
  double canvasHeight = 0;

  // Lista de elementos dibujables en el lienzo.
  final List<Drawable> drawables = [];

  // Texto mostrado en pantalla según estado actual.
  String get responseText =>
      _isInitial ? "..." : (_isLoading ? "Esperant ..." : _responseText);

  // Getters públicos de estado y selección.
  bool get isLoading => _isLoading;
  int? get selectedShapeIndex => _selectedShapeIndex;
  Drawable? get selectedShape =>
      _selectedShapeIndex != null && _selectedShapeIndex! < drawables.length
          ? drawables[_selectedShapeIndex!]
          : null;

  // Inicializa cliente HTTP reutilizable.
  AppData() {
    _httpClient = HttpClient();
    _ioClient = IOClient(_httpClient!);
    _client = _ioClient;
  }

  // Cambia estado de carga y notifica a la UI.
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Añade una forma al canvas y refresca la UI.
  void addDrawable(Drawable drawable) {
    drawables.add(drawable);
    notifyListeners();
  }

  // Guarda la forma seleccionada por índice.
  void selectShape(int index) {
    if (index >= 0 && index < drawables.length) {
      _selectedShapeIndex = index;
    }
    notifyListeners();
  }

  // Limpia la selección actual.
  void deselectShape() {
    _selectedShapeIndex = null;
    notifyListeners();
  }

  // Elimina la forma seleccionada si existe.
  void deleteSelectedShape() {
    if (_selectedShapeIndex != null && _selectedShapeIndex! < drawables.length) {
      drawables.removeAt(_selectedShapeIndex!);
      _selectedShapeIndex = null;
      notifyListeners();
    }
  }

  void updateShapeProperty(int index, String property, dynamic value) {
    if (index >= 0 && index < drawables.length) {
      final shape = drawables[index];
      
      // Actualiza propiedades de círculos creando una nueva instancia.
      if (shape is Circle) {
        switch (property) {
          case 'x':
            drawables[index] = Circle(
              center: Offset(parseDouble(value), shape.center.dy),
              radius: shape.radius,
              color: shape.color,
              strokeWidth: shape.strokeWidth,
              gradientColors: shape.gradientColors,
            );
            break;
          case 'y':
            drawables[index] = Circle(
              center: Offset(shape.center.dx, parseDouble(value)),
              radius: shape.radius,
              color: shape.color,
              strokeWidth: shape.strokeWidth,
              gradientColors: shape.gradientColors,
            );
            break;
          case 'radius':
            drawables[index] = Circle(
              center: shape.center,
              radius: parseDouble(value),
              color: shape.color,
              strokeWidth: shape.strokeWidth,
              gradientColors: shape.gradientColors,
            );
            break;
          case 'color':
            drawables[index] = Circle(
              center: shape.center,
              radius: shape.radius,
              color: parseColor(value),
              strokeWidth: shape.strokeWidth,
              gradientColors: shape.gradientColors,
            );
            break;
          case 'strokeWidth':
            drawables[index] = Circle(
              center: shape.center,
              radius: shape.radius,
              color: shape.color,
              strokeWidth: parseDouble(value),
              gradientColors: shape.gradientColors,
            );
            break;
        }
      // Actualiza propiedades de rectángulos creando una nueva instancia.
      } else if (shape is Rectangle) {
        switch (property) {
          case 'topLeftX':
            drawables[index] = Rectangle(
              topLeft: Offset(parseDouble(value), shape.topLeft.dy),
              bottomRight: shape.bottomRight,
              color: shape.color,
              strokeWidth: shape.strokeWidth,
              gradientColors: shape.gradientColors,
            );
            break;
          case 'topLeftY':
            drawables[index] = Rectangle(
              topLeft: Offset(shape.topLeft.dx, parseDouble(value)),
              bottomRight: shape.bottomRight,
              color: shape.color,
              strokeWidth: shape.strokeWidth,
              gradientColors: shape.gradientColors,
            );
            break;
          case 'bottomRightX':
            drawables[index] = Rectangle(
              topLeft: shape.topLeft,
              bottomRight: Offset(parseDouble(value), shape.bottomRight.dy),
              color: shape.color,
              strokeWidth: shape.strokeWidth,
              gradientColors: shape.gradientColors,
            );
            break;
          case 'bottomRightY':
            drawables[index] = Rectangle(
              topLeft: shape.topLeft,
              bottomRight: Offset(shape.bottomRight.dx, parseDouble(value)),
              color: shape.color,
              strokeWidth: shape.strokeWidth,
              gradientColors: shape.gradientColors,
            );
            break;
          case 'color':
            drawables[index] = Rectangle(
              topLeft: shape.topLeft,
              bottomRight: shape.bottomRight,
              color: parseColor(value),
              strokeWidth: shape.strokeWidth,
              gradientColors: shape.gradientColors,
            );
            break;
          case 'strokeWidth':
            drawables[index] = Rectangle(
              topLeft: shape.topLeft,
              bottomRight: shape.bottomRight,
              color: shape.color,
              strokeWidth: parseDouble(value),
              gradientColors: shape.gradientColors,
            );
            break;
        }
      // Actualiza propiedades de líneas creando una nueva instancia.
      } else if (shape is Line) {
        switch (property) {
          case 'startX':
            drawables[index] = Line(
              start: Offset(parseDouble(value), shape.start.dy),
              end: shape.end,
              color: shape.color,
              strokeWidth: shape.strokeWidth,
            );
            break;
          case 'startY':
            drawables[index] = Line(
              start: Offset(shape.start.dx, parseDouble(value)),
              end: shape.end,
              color: shape.color,
              strokeWidth: shape.strokeWidth,
            );
            break;
          case 'endX':
            drawables[index] = Line(
              start: shape.start,
              end: Offset(parseDouble(value), shape.end.dy),
              color: shape.color,
              strokeWidth: shape.strokeWidth,
            );
            break;
          case 'endY':
            drawables[index] = Line(
              start: shape.start,
              end: Offset(shape.end.dx, parseDouble(value)),
              color: shape.color,
              strokeWidth: shape.strokeWidth,
            );
            break;
          case 'color':
            drawables[index] = Line(
              start: shape.start,
              end: shape.end,
              color: parseColor(value),
              strokeWidth: shape.strokeWidth,
            );
            break;
          case 'strokeWidth':
            drawables[index] = Line(
              start: shape.start,
              end: shape.end,
              color: shape.color,
              strokeWidth: parseDouble(value),
            );
            break;
        }
      // Actualiza propiedades de texto creando una nueva instancia.
      } else if (shape is TextElement) {
        switch (property) {
          case 'x':
            drawables[index] = TextElement(
              text: shape.text,
              position: Offset(parseDouble(value), shape.position.dy),
              color: shape.color,
              fontSize: shape.fontSize,
              fontWeight: shape.fontWeight,
              fontStyle: shape.fontStyle,
            );
            break;
          case 'y':
            drawables[index] = TextElement(
              text: shape.text,
              position: Offset(shape.position.dx, parseDouble(value)),
              color: shape.color,
              fontSize: shape.fontSize,
              fontWeight: shape.fontWeight,
              fontStyle: shape.fontStyle,
            );
            break;
          case 'color':
            drawables[index] = TextElement(
              text: shape.text,
              position: shape.position,
              color: parseColor(value),
              fontSize: shape.fontSize,
              fontWeight: shape.fontWeight,
              fontStyle: shape.fontStyle,
            );
            break;
          case 'fontSize':
            drawables[index] = TextElement(
              text: shape.text,
              position: shape.position,
              color: shape.color,
              fontSize: parseDouble(value),
              fontWeight: shape.fontWeight,
              fontStyle: shape.fontStyle,
            );
            break;
        }
      }
      notifyListeners();
    }
  }

  // Hit-test: comprueba si un punto cae dentro de una forma.
  bool isPointInShape(Offset point, Drawable shape) {
    if (shape is Circle) {
      final distance = (point - shape.center).distance;
      return distance <= shape.radius;
    } else if (shape is Rectangle) {
      final rect = Rect.fromPoints(shape.topLeft, shape.bottomRight);
      return rect.contains(point);
    } else if (shape is Line) {
      const threshold = 10.0;
      final dist = _distancePointToLine(point, shape.start, shape.end);
      return dist <= threshold;
    } else if (shape is TextElement) {
      const hitBoxSize = 20.0;
      final dx = (point.dx - shape.position.dx).abs();
      final dy = (point.dy - shape.position.dy).abs();
      return dx <= hitBoxSize && dy <= hitBoxSize;
    }
    return false;
  }

  // Distancia mínima de un punto a un segmento de línea.
  double _distancePointToLine(Offset point, Offset start, Offset end) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    if (dx == 0 && dy == 0) {
      return (point - start).distance;
    }
    final t = ((point.dx - start.dx) * dx + (point.dy - start.dy) * dy) /
        (dx * dx + dy * dy);
    final t_clamped = t.clamp(0.0, 1.0);
    final closest = Offset(start.dx + t_clamped * dx, start.dy + t_clamped * dy);
    return (point - closest).distance;
  }

  // Selecciona la forma superior bajo una posición del canvas.
  void selectShapeAtPosition(Offset position) {
    for (int i = drawables.length - 1; i >= 0; i--) {
      if (isPointInShape(position, drawables[i])) {
        selectShape(i);
        return;
      }
    }
    deselectShape();
  }

  // Llama al endpoint de generación en streaming y acumula texto.
  Future<void> callStream({required String question}) async {
    _isInitial = false;
    setLoading(true);

    try {
      var request = http.Request(
        'POST',
        Uri.parse('http://localhost:11434/api/generate'),
      );

      request.headers.addAll({'Content-Type': 'application/json'});
      request.body = jsonEncode(
          {'model': streamingModel, 'prompt': question, 'stream': true});

      var streamedResponse = await _client!.send(request);
      _streamSubscription =
          streamedResponse.stream.transform(utf8.decoder).listen((value) {
        var jsonResponse = jsonDecode(value);
        var jsonResponseStr = jsonResponse['response'];
        _responseText = "$_responseText\n$jsonResponseStr";
        notifyListeners();
      }, onError: (error) {
        if (error is http.ClientException &&
            error.message == 'Connection closed while receiving data') {
          _responseText += "\nRequest cancelled.";
        } else {
          _responseText += "\nError during streaming: $error";
        }
        setLoading(false);
        notifyListeners();
      }, onDone: () {
        setLoading(false);
      });
    } catch (e) {
      _responseText = "\nError during streaming.";
      setLoading(false);
      notifyListeners();
    }
  }

  // Recorre estructuras anidadas y corrige JSON que venga como string.
  Future<dynamic> fixJsonInStrings(dynamic data) async {
    if (data is Map<String, dynamic>) {
      final result = <String, dynamic>{};
      for (final entry in data.entries) {
        result[entry.key] = await fixJsonInStrings(entry.value);
      }
      return result;
    } else if (data is List) {
      return Future.wait(data.map((value) => fixJsonInStrings(value)));
    } else if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) {
        return data;
      }

      try {
        // Si és JSON dins d'una cadena, el deserialitzem
        final parsed = jsonDecode(data);
        return fixJsonInStrings(parsed);
      } catch (_) {
        if (_looksLikeJsonCandidate(trimmed)) {
          final repairedJson = await _repairJsonWithAi(trimmed);
          if (repairedJson != null) {
            return fixJsonInStrings(repairedJson);
          }
        }

        // Si no és JSON o no es pot reparar, retornem la cadena tal qual
        return data;
      }
    }
    // Retorna qualsevol altre tipus sense canvis (números, booleans, etc.)
    return data;
  }

  // Heurística rápida para detectar si un string parece JSON.
  bool _looksLikeJsonCandidate(String value) {
    return value.startsWith('{') ||
        value.startsWith('[') ||
        ((value.contains('{') || value.contains('[')) && value.contains(':'));
  }

        // Pide al modelo que repare JSON malformado y devuelve objeto parseado.
  Future<dynamic> _repairJsonWithAi(String rawJson) async {
    const apiUrl = 'http://localhost:11434/api/chat';
    final body = {
      "model": jsonFixModel,
      "stream": false,
      "format": "json",
      "messages": [
        {
          "role": "system",
          "content":
              "You repair malformed JSON. Return only valid JSON that preserves the original intent and values as closely as possible."
        },
        {
          "role": "user",
          "content":
              "Repair this malformed JSON and return only the fixed JSON:\n$rawJson"
        }
      ]
    };

    try {
      final response = await _client!.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final jsonResponse = jsonDecode(response.body);
      final content = jsonResponse['message']?['content'];
      if (content is! String || content.trim().isEmpty) {
        return null;
      }

      return jsonDecode(content);
    } catch (_) {
      return null;
    }
  }

  // Limpia espacios en claves de mapas (incluyendo estructuras anidadas).
  dynamic cleanKeys(dynamic value) {
    if (value is Map<String, dynamic>) {
      final result = <String, dynamic>{};
      value.forEach((k, v) {
        result[k.trim()] = cleanKeys(v);
      });
      return result;
    }
    if (value is List) {
      return value.map(cleanKeys).toList();
    }
    return value;
  }

  // Llama al endpoint con tools y ejecuta funciones devueltas por el modelo.
  Future<void> callWithCustomTools({required String userPrompt}) async {
    const apiUrl = 'http://localhost:11434/api/chat';
    _isInitial = false;
    setLoading(true);

    // Incluye tamaño del canvas para que el modelo dibuje con contexto.
    final sizeInfo = "Canvas size: width=${canvasWidth.toStringAsFixed(1)}, height=${canvasHeight.toStringAsFixed(1)}.";

    final body = {
      "model": functionCallingModel,
      "stream": false,
      "messages": [
        {"role": "system", "content": sizeInfo},
        {"role": "user", "content": userPrompt}
      ],
      "tools": tools
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['message'] != null &&
            jsonResponse['message']['tool_calls'] != null) {
          final toolCalls = (jsonResponse['message']['tool_calls'] as List)
              .map((e) => cleanKeys(e))
              .toList();
          for (final tc in toolCalls) {
            if (tc['function'] != null) {
              await _processFunctionCall(tc['function']);
            }
          }
        }
        setLoading(false);
      } else {
        setLoading(false);
        throw Exception("Error: ${response.body}");
      }
    } catch (e) {
      print("Error during API call: $e");
      setLoading(false);
    }
  }

  // Cancela streams activos y reinicia el cliente HTTP.
  void cancelRequests() {
    _streamSubscription?.cancel();
    _httpClient?.close(force: true);
    _httpClient = HttpClient();
    _ioClient = IOClient(_httpClient!);
    _client = _ioClient;
    _responseText += "\nRequest cancelled.";
    setLoading(false);
    notifyListeners();
  }

  // Convierte dinámicos a double con fallback seguro.
  double parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  // Convierte nombre de color (string) a Color.
  Color parseColor(dynamic value) {
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'red':
          return Colors.red;
        case 'blue':
          return Colors.blue;
        case 'green':
          return Colors.green;
        case 'yellow':
          return Colors.yellow;
        case 'black':
          return Colors.black;
        case 'white':
          return Colors.white;
        case 'orange':
          return Colors.orange;
        case 'purple':
          return Colors.purple;
        case 'pink':
          return Colors.pink;
        case 'brown':
          return Colors.brown;
        case 'grey':
        case 'gray':
          return Colors.grey;
        default:
          return Colors.black;
      }
    }
    return Colors.black;
  }

  // Convierte lista dinámica en lista de colores.
  List<Color> parseGradientColors(dynamic value) {
    if (value is List) {
      return value.map((color) => parseColor(color)).toList();
    }
    return [];
  }

  // Convierte texto de peso de fuente a FontWeight.
  FontWeight parseFontWeight(dynamic value) {
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'bold':
        case 'w700':
          return FontWeight.bold;
        case 'w600':
        case 'semibold':
          return FontWeight.w600;
        case 'w500':
        case 'medium':
          return FontWeight.w500;
        case 'w400':
        case 'normal':
        case 'regular':
          return FontWeight.normal;
        case 'w300':
        case 'light':
          return FontWeight.w300;
        case 'w200':
          return FontWeight.w200;
        case 'w100':
        case 'thin':
          return FontWeight.w100;
        case 'w800':
          return FontWeight.w800;
        case 'w900':
          return FontWeight.w900;
        default:
          return FontWeight.normal;
      }
    }
    return FontWeight.normal;
  }

  // Convierte texto de estilo de fuente a FontStyle.
  FontStyle parseFontStyle(dynamic value) {
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'italic':
          return FontStyle.italic;
        case 'normal':
          return FontStyle.normal;
        default:
          return FontStyle.normal;
      }
    }
    return FontStyle.normal;
  }

  // Devuelve un valor aleatorio entre dos límites.
  double _randomBetween(double min, double max) {
    return min + Random().nextDouble() * (max - min);
  }

  // Ejecuta una función/tool devuelta por el modelo y añade la forma correspondiente.
  Future<void> _processFunctionCall(Map<String, dynamic> functionCall) async {
    final fixedJson = await fixJsonInStrings(functionCall);
    final parametersData = fixedJson['arguments'];
    final parameters = parametersData is Map<String, dynamic>
        ? parametersData
        : <String, dynamic>{};

    String name = fixedJson['name'];
    String infoText = "Draw $name: $parameters";

    print(infoText);
    _responseText = "$_responseText\n$infoText";

    switch (name) {
      // Dibuja un círculo con defaults cuando faltan parámetros.
      case 'draw_circle':
        final dx =
            parameters['x'] != null ? parseDouble(parameters['x']) : 50.0;
        final dy =
            parameters['y'] != null ? parseDouble(parameters['y']) : 50.0;
        final radius = parameters['radius'] != null
            ? parseDouble(parameters['radius'])
            : 10.0;
        final color = parseColor(parameters['color']);
        final strokeWidth = parameters['strokeWidth'] != null
            ? parseDouble(parameters['strokeWidth'])
            : 2.0;
        final gradientColors = parseGradientColors(parameters['gradientColors']);
        addDrawable(
          Circle(
            center: Offset(dx, dy),
            radius: max(0.0, radius),
            color: color,
            strokeWidth: strokeWidth,
            gradientColors: gradientColors.isNotEmpty ? gradientColors : null,
          ),
        );
        break;

      // Dibuja una línea con defaults/aleatorios cuando faltan coordenadas.
      case 'draw_line':
        final startX = parameters['startX'] != null
            ? parseDouble(parameters['startX'])
            : _randomBetween(10.0, 100.0);
        final startY = parameters['startY'] != null
            ? parseDouble(parameters['startY'])
            : _randomBetween(10.0, 100.0);
        final endX = parameters['endX'] != null
            ? parseDouble(parameters['endX'])
            : _randomBetween(10.0, 100.0);
        final endY = parameters['endY'] != null
            ? parseDouble(parameters['endY'])
            : _randomBetween(10.0, 100.0);
        final color = parseColor(parameters['color']);
        final strokeWidth = parameters['strokeWidth'] != null
            ? parseDouble(parameters['strokeWidth'])
            : 1.0;
        final start = Offset(startX, startY);
        final end = Offset(endX, endY);
        addDrawable(Line(start: start, end: end, color: color, strokeWidth: strokeWidth));
        break;

      // Dibuja un rectángulo cuando llegan todas las coordenadas necesarias.
      case 'draw_rectangle':
        if (parameters['topLeftX'] != null &&
            parameters['topLeftY'] != null &&
            parameters['bottomRightX'] != null &&
            parameters['bottomRightY'] != null) {
          final topLeftX = parseDouble(parameters['topLeftX']);
          final topLeftY = parseDouble(parameters['topLeftY']);
          final bottomRightX = parseDouble(parameters['bottomRightX']);
          final bottomRightY = parseDouble(parameters['bottomRightY']);
          final color = parseColor(parameters['color']);
          final strokeWidth = parameters['strokeWidth'] != null
              ? parseDouble(parameters['strokeWidth'])
              : 2.0;
          final gradientColors = parseGradientColors(parameters['gradientColors']);
          final topLeft = Offset(topLeftX, topLeftY);
          final bottomRight = Offset(bottomRightX, bottomRightY);
          addDrawable(Rectangle(
            topLeft: topLeft,
            bottomRight: bottomRight,
            color: color,
            strokeWidth: strokeWidth,
            gradientColors: gradientColors.isNotEmpty ? gradientColors : null,
          ));
        } else {
          print("Missing rectangle properties: $parameters");
        }
        break;

      // Dibuja texto con estilo opcional.
      case 'draw_text':
        if (parameters['x'] != null &&
            parameters['y'] != null &&
            parameters['text'] != null) {
          final x = parseDouble(parameters['x']);
          final y = parseDouble(parameters['y']);
          final text = parameters['text'].toString();
          final color = parseColor(parameters['color']);
          final fontSize = parameters['fontSize'] != null
              ? parseDouble(parameters['fontSize'])
              : 14.0;
          final fontWeight = parseFontWeight(parameters['fontWeight']);
          final fontStyle = parseFontStyle(parameters['fontStyle']);
          addDrawable(TextElement(
            position: Offset(x, y),
            text: text,
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
          ));
        } else {
          print("Missing text properties: $parameters");
        }
        break;

      // Fallback para tools no soportadas.
      default:
        print("Unknown function call: ${fixedJson['name']}");
    }
  }
}
