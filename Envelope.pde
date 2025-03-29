class Envelope {
  PVector position;
  float width, height;
  float openness = 0;
  color staticColor;
  ColorPalette palette;
  
  Envelope(float x, float y, float w, float h, ColorPalette p) {
    position = new PVector(x, y);
    width = w;
    height = h;
    palette = p;
    staticColor = palette.getBaseColor(); // Asignamos un color fijo
  }
  
  void update(float audioLevel) {
    if (audioLevel > sensitivity) {
      openness = 1;
      // Ya no cambiamos el color aquí
    } else {
      openness = max(0, openness - 0.05);
      // Ya no cambiamos el color aquí
    }
  }
  
  void display() {
    pushMatrix();
    translate(position.x, position.y, 0);
   
    // Iluminación UNIFICADA para todos los sobres, independientemente de su estado
    // Luz ambiental suave
    ambientLight(150, 150, 150,  // Color blanco suave uniforme para todos
      700, 400, -100);
    // Luz direccional principal
    directionalLight(
      120, 120, 120,  // Color blanco suave uniforme para todos
      700, -400, 100);      // Dirección fija desde arriba
     directionalLight(
      120, 120, 120,  // Color blanco suave uniforme para todos
      700, 400, 100);      // Dirección fija desde arriba
    // Colores para distintas partes del sobre (ahora fijos)
    color baseColor = staticColor;
    color darkColor = lerpColor(baseColor, color(0), 0.3); // Para laterales
    color lightColor = lerpColor(baseColor, color(255), 0.1); // Para solapa
    
    float depth = 2; // Profundidad reducida a un valor fijo
    
    // Base del sobre (parte posterior)
    fill(darkColor);
    noStroke();
    pushMatrix();
    translate(0, 0, -depth);
    rect(0, 0, width, height);
    popMatrix();
    
    // Laterales del sobre
    fill(darkColor);
    
    // Lateral izquierdo
    beginShape();
    vertex(0, 0, 0);
    vertex(0, 0, -depth);
    vertex(0, height, -depth);
    vertex(0, height, 0);
    endShape(CLOSE);
    
    // Lateral derecho
    beginShape();
    vertex(width, 0, 0);
    vertex(width, 0, -depth);
    vertex(width, height, -depth);
    vertex(width, height, 0);
    endShape(CLOSE);
    
    // Lateral inferior
    beginShape();
    vertex(0, height, 0);
    vertex(width, height, 0);
    vertex(width, height, -depth);
    vertex(0, height, -depth);
    endShape(CLOSE);
    
    // Parte frontal pentagonal (5 nodos)
    fill(baseColor);
    beginShape();
    // Base inferior (2 nodos)
    vertex(0, height, 0);                // Nodo 1: Esquina inferior izquierda
    vertex(width, height, 0);            // Nodo 2: Esquina inferior derecha
    
    // Parte superior (3 nodos)
    vertex(width, 0, 0);                // Nodo 3: Esquina superior derecha
    vertex(width/2, height * 0.4, 0);    // Nodo 4: Pico central al 40% de altura
    vertex(0, 0, 0);                    // Nodo 5: Esquina superior izquierda
    endShape(CLOSE);
    
    // Solapa animada (se abre desde la parte superior)
    float angle = map(openness, 0, 1, 0, PI/2);
    
    if (openness > 0) {
      pushMatrix();
      // El pivote está en el centro de la línea superior
      translate(width/2, 0, 0);
      rotateX(angle);
      
      // Dibujar la solapa triangular que apunta hacia abajo
      fill(lightColor);
      beginShape();
      vertex(-width/2, 0, -2);            // Esquina superior izquierda
      vertex(width/2, 0, -2);             // Esquina superior derecha
      vertex(0, height * 0.4, 0);        // Punta hacia el pico central
      endShape(CLOSE);
      popMatrix();
    }
    
    // IMPORTANTE: Desactivar las luces AL FINAL para no afectar al resto de la escena
    noLights();
    
    popMatrix();
  }
}
