import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
import 'canvas_painter.dart';
import 'drawable.dart';

class Layout extends StatefulWidget {
  const Layout({super.key, required this.title});

  final String title;

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  String _colorToName(Color color) {
    // simple reverse mapping for known colors
    if (color == Colors.red) return 'red';
    if (color == Colors.blue) return 'blue';
    if (color == Colors.green) return 'green';
    if (color == Colors.yellow) return 'yellow';
    if (color == Colors.black) return 'black';
    if (color == Colors.white) return 'white';
    if (color == Colors.orange) return 'orange';
    if (color == Colors.purple) return 'purple';
    if (color == Colors.pink) return 'pink';
    if (color == Colors.brown) return 'brown';
    if (color == Colors.grey) return 'grey';
    // fallback to hex
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // `appData` concentra todo el estado global: figuras, selección y peticiones al modelo.
    final appData = Provider.of<AppData>(context);
    // Controlador del área de texto de respuestas (panel derecho superior).
    final ScrollController scrollController = ScrollController();
    // Controlador del input donde el usuario escribe prompts.
    final TextEditingController textController = TextEditingController();

    // Lista de ejemplos para el placeholder del input.
    final random = Random();
    final placeholders = [
      'Draw a line from 10, 50 to 100, 25 ...',
      'Draw two lines and two circles',
      'Draw a circle centered at 150, 200 with radius 50 ...',
      'Make a rectangle between x=10, y=20 and x=100, y=200 ...',
      'Draw a circle at position 50,100 with radius 34.66',
    ];

    // Estructura general:
    // - Izquierda: canvas de dibujo.
    // - Derecha: salida textual + caja de prompt + botones.
    // - Encima de todo: overlay de carga cuando se está procesando.
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(widget.title),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Capa base de la pantalla: dos columnas horizontales.
              Row(
                children: [
                  // Columna izquierda (2/3 aprox): zona de canvas interactiva.
                  Expanded(
                    flex: 2,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Se actualiza el tamaño del canvas en el modelo para que
                        // el LLM tenga contexto de dimensiones reales al dibujar.
                        appData.canvasWidth = constraints.maxWidth;
                        appData.canvasHeight = constraints.maxHeight;
                        return GestureDetector(
                          // Al hacer click/tap en el canvas se intenta seleccionar
                          // la forma superior que contenga ese punto.
                          onTapDown: (details) {
                            appData.selectShapeAtPosition(details.localPosition);
                          },
                          child: Container(
                            color: CupertinoColors.systemGrey5,
                            child: CustomPaint(
                              // `CanvasPainter` renderiza todas las figuras y resalta
                              // la figura seleccionada (si existe).
                              painter: CanvasPainter(
                                drawables: appData.drawables,
                                selectedIndex: appData.selectedShapeIndex,
                              ),
                              child: Container(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Columna derecha (1/3 aprox): consola textual + input + acciones.
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        // Área de salida: muestra la respuesta acumulada del modelo,
                        // incluyendo tool calls y mensajes de estado.
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: CupertinoScrollbar(
                              controller: scrollController,
                              child: SingleChildScrollView(
                                controller: scrollController,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    appData.responseText,
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Caja de texto para introducir la instrucción al modelo.
                        // Se deshabilita mientras hay una petición activa.
                        SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CDKFieldText(
                              maxLines: 5,
                              controller: textController,
                              placeholder: placeholders[
                                  random.nextInt(placeholders.length)],
                              enabled:
                                  !appData.isLoading, // Desactiva si carregant
                            ),
                          ),
                        ),
                        // Fila de acciones principales:
                        // - Query: envía prompt y ejecuta tool calling.
                        // - Cancel: detiene la petición en curso.
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: CDKButton(
                                  style: CDKButtonStyle.action,
                                  onPressed: appData.isLoading
                                      ? null
                                      : () {
                                          // Envía el prompt actual al flujo con tools.
                                          final userPrompt =
                                              textController.text;
                                          appData.callWithCustomTools(
                                              userPrompt: userPrompt);
                                        },
                                  child: const Text('Query'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: CDKButton(
                                  onPressed: appData.isLoading
                                      ? () => appData.cancelRequests()
                                      : null,
                                  child: const Text('Cancel'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Overlay de bloqueo visual durante carga:
              // evita interacción accidental y comunica estado ocupado.
              if (appData.isLoading)
                Positioned.fill(
                  child: Container(
                    color: CupertinoColors.systemGrey.withOpacity(0.5),
                    child: const Center(
                      child: CupertinoActivityIndicator(
                        radius: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ));
  }

}
