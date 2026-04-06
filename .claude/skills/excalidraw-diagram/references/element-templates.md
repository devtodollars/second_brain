# Element Templates

Copy-paste JSON templates for each Excalidraw element type.
Pull fill/stroke colors from `color-palette.md` based on each element's semantic purpose.

---

## Free-Floating Text

```json
{
  "id": "text_id",
  "type": "text",
  "x": 100,
  "y": 100,
  "width": 200,
  "height": 25,
  "text": "Label",
  "originalText": "Label",
  "fontSize": 16,
  "fontFamily": 3,
  "textAlign": "center",
  "verticalAlign": "middle",
  "strokeColor": "#374151",
  "backgroundColor": "transparent",
  "fillStyle": "solid",
  "strokeWidth": 1,
  "roughness": 0,
  "opacity": 100,
  "boundElements": []
}
```

---

## Rectangle (Process / Action)

```json
{
  "id": "rect_id",
  "type": "rectangle",
  "x": 100,
  "y": 100,
  "width": 180,
  "height": 90,
  "text": "Process",
  "originalText": "Process",
  "fontSize": 16,
  "fontFamily": 3,
  "textAlign": "center",
  "verticalAlign": "middle",
  "strokeColor": "#374151",
  "backgroundColor": "#f3f4f6",
  "fillStyle": "solid",
  "strokeWidth": 2,
  "roughness": 0,
  "opacity": 100,
  "boundElements": []
}
```

---

## Ellipse (Start / End)

```json
{
  "id": "ellipse_id",
  "type": "ellipse",
  "x": 100,
  "y": 100,
  "width": 140,
  "height": 70,
  "text": "Start",
  "originalText": "Start",
  "fontSize": 16,
  "fontFamily": 3,
  "textAlign": "center",
  "verticalAlign": "middle",
  "strokeColor": "#2563eb",
  "backgroundColor": "#dbeafe",
  "fillStyle": "solid",
  "strokeWidth": 2,
  "roughness": 0,
  "opacity": 100,
  "boundElements": []
}
```

---

## Diamond (Decision)

```json
{
  "id": "diamond_id",
  "type": "diamond",
  "x": 100,
  "y": 100,
  "width": 160,
  "height": 80,
  "text": "Condition?",
  "originalText": "Condition?",
  "fontSize": 16,
  "fontFamily": 3,
  "textAlign": "center",
  "verticalAlign": "middle",
  "strokeColor": "#ca8a04",
  "backgroundColor": "#fef9c3",
  "fillStyle": "solid",
  "strokeWidth": 2,
  "roughness": 0,
  "opacity": 100,
  "boundElements": []
}
```

---

## Arrow

```json
{
  "id": "arrow_id",
  "type": "arrow",
  "x": 100,
  "y": 100,
  "width": 120,
  "height": 0,
  "points": [[0, 0], [120, 0]],
  "startBinding": {
    "elementId": "source_element_id",
    "focus": 0,
    "gap": 8
  },
  "endBinding": {
    "elementId": "target_element_id",
    "focus": 0,
    "gap": 8
  },
  "strokeColor": "#374151",
  "backgroundColor": "transparent",
  "fillStyle": "solid",
  "strokeWidth": 2,
  "roughness": 0,
  "opacity": 100,
  "startArrowhead": null,
  "endArrowhead": "arrow",
  "boundElements": []
}
```

---

## Line (Divider / Timeline Spine)

```json
{
  "id": "line_id",
  "type": "line",
  "x": 100,
  "y": 100,
  "width": 0,
  "height": 300,
  "points": [[0, 0], [0, 300]],
  "strokeColor": "#d1d5db",
  "backgroundColor": "transparent",
  "fillStyle": "solid",
  "strokeWidth": 1,
  "strokeStyle": "dashed",
  "roughness": 0,
  "opacity": 100,
  "boundElements": []
}
```

---

## Small Dot (Timeline Marker)

```json
{
  "id": "dot_id",
  "type": "ellipse",
  "x": 95,
  "y": 145,
  "width": 12,
  "height": 12,
  "text": "",
  "originalText": "",
  "strokeColor": "#374151",
  "backgroundColor": "#374151",
  "fillStyle": "solid",
  "strokeWidth": 1,
  "roughness": 0,
  "opacity": 100,
  "boundElements": []
}
```

---

## Evidence Artifact (Code / JSON Block)

```json
{
  "id": "artifact_id",
  "type": "rectangle",
  "x": 100,
  "y": 100,
  "width": 280,
  "height": 120,
  "text": "{ \"key\": \"value\" }",
  "originalText": "{ \"key\": \"value\" }",
  "fontSize": 13,
  "fontFamily": 3,
  "textAlign": "left",
  "verticalAlign": "top",
  "strokeColor": "#334155",
  "backgroundColor": "#1e293b",
  "fillStyle": "solid",
  "strokeWidth": 1,
  "roughness": 0,
  "opacity": 100,
  "boundElements": []
}
```
