// Defines the tools/functions available in Flutter
const tools = [
  {
    "type": "function",
    "function": {
      "name": "draw_circle",
      "description":
          "Draw a circle with a specified radius. If the radius is missing, use 10 as default. If the radius should be random, use a random value between 10 and 25. You can specify fillColor (or color) for the fill, strokeColor for the border, strokeWidth for outline thickness, and gradientColors as an array of strings for a linear gradient fill.",
      "parameters": {
        "type": "object",
        "properties": {
          "x": {"type": "number"},
          "y": {"type": "number"},
          "radius": {"type": "number"},
          "color": {"type": "string"},
          "fillColor": {"type": "string"},
          "strokeColor": {"type": "string"},
          "strokeWidth": {"type": "number"},
          "gradientColors": {
            "type": "array",
            "items": {"type": "string"}
          }
        },
        "required": ["x", "y", "radius"]
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "draw_line",
      "description":
          "Draw a line between two points. If positions are not specified, choose random points between x=10, y=10 and x=100, y=100. You can specify the color as a string (e.g., 'red', 'blue', 'green', etc.) and stroke width.",
      "parameters": {
        "type": "object",
        "properties": {
          "startX": {"type": "number"},
          "startY": {"type": "number"},
          "endX": {"type": "number"},
          "endY": {"type": "number"},
          "color": {"type": "string"},
          "strokeWidth": {"type": "number"}
        },
        "required": ["startX", "startY", "endX", "endY"]
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "draw_rectangle",
      "description":
          "Draw a rectangle defined by the top-left and bottom-right coordinates. You can specify fillColor (or color) for the fill, strokeColor for the border, strokeWidth for outline thickness, or gradientColors as an array of strings for a linear gradient fill.",
      "parameters": {
        "type": "object",
        "properties": {
          "topLeftX": {"type": "number"},
          "topLeftY": {"type": "number"},
          "bottomRightX": {"type": "number"},
          "bottomRightY": {"type": "number"},
          "color": {"type": "string"},
          "fillColor": {"type": "string"},
          "strokeColor": {"type": "string"},
          "strokeWidth": {"type": "number"},
          "gradientColors": {
            "type": "array",
            "items": {"type": "string"}
          }
        },
        "required": ["topLeftX", "topLeftY", "bottomRightX", "bottomRightY"]
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "draw_text",
      "description":
        "Draw a text string at a specified position. You can specify the color as a string (e.g., 'red', 'blue', 'green', etc.), font size, font weight (e.g., 'bold', 'normal', 'light'), and font style (e.g., 'italic', 'normal').",
      "parameters": {
        "type": "object",
        "properties": {
          "text": {"type": "string"},
          "x": {"type": "number"},
          "y": {"type": "number"},
          "color": {"type": "string"},
          "fontSize": {"type": "number"},
          "fontWeight": {"type": "string"},
          "fontStyle": {"type": "string"}
        },
        "required": ["text", "x", "y"]
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "select_shape",
      "description": "Select a shape by its index in the current canvas list. If no index is provided, it can select the last created shape.",
      "parameters": {
        "type": "object",
        "properties": {
          "id": {"type": "integer"},
          "last": {"type": "boolean"}
        }
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "delete_shape",
      "description": "Delete the currently selected shape. If an index is provided, it can be used to target that shape, but the intended flow is to work with the current selection.",
      "parameters": {
        "type": "object",
        "properties": {
          "id": {"type": "integer"}
        }
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "update_shape",
      "description":
          "Modifies the properties of the currently selected shape. For circles: x, y, radius, color/fillColor, strokeWidth, gradientColors. For rectangles: topLeftX, topLeftY, bottomRightX, bottomRightY, width, height, color/fillColor, strokeWidth, gradientColors. For lines: startX, startY, endX, endY, color/strokeColor, strokeWidth. For text: x, y, text, color, fontSize, fontWeight, fontStyle, bold. You can specify 'id' to target a specific shape index, otherwise it updates the selected shape.",
      "parameters": {
        "type": "object",
        "properties": {
          "id": {"type": "integer"},
          "color": {"type": "string"},
          "fillColor": {"type": "string"},
          "strokeColor": {"type": "string"},
          "strokeWidth": {"type": "number"},
          "x": {"type": "number"},
          "y": {"type": "number"},
          "radius": {"type": "number"},
          "width": {"type": "number"},
          "height": {"type": "number"},
          "topLeftX": {"type": "number"},
          "topLeftY": {"type": "number"},
          "bottomRightX": {"type": "number"},
          "bottomRightY": {"type": "number"},
          "startX": {"type": "number"},
          "startY": {"type": "number"},
          "endX": {"type": "number"},
          "endY": {"type": "number"},
          "text": {"type": "string"},
          "fontSize": {"type": "number"},
          "fontWeight": {"type": "string"},
          "fontStyle": {"type": "string"},
          "bold": {"type": "boolean"},
          "gradientColors": {
            "type": "array",
            "items": {"type": "string"}
          }
        }
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "clear_canvas",
      "description": "Clear the entire drawing.",
      "parameters": {
        "type": "object",
        "properties": {}
      }
    }
  }
];
