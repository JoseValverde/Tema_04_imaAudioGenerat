import processing.sound.*;
import peasy.*;

PeasyCam cam;
AudioAnalyzer analyzer;
Envelope[][] envelopes;
CameraController cameraController;
ColorPalette palette;

int rows = 14;
int cols = 10;
float sensitivity = 0.00000005; // Aumenta este valor (era 0.01)
boolean showDebugElements = false; // Variable para activar/desactivar visualización

void setup() {
  size(1200, 800, P3D);
  smooth(8);
  
  palette = new ColorPalette();
  analyzer = new AudioAnalyzer(this, "mp3/music.mp3");
  cameraController = new CameraController(this);

  initializeEnvelopes();
}

void draw() {
  background(20);
  noLights(); // Desactivar todas las luces al inicio de cada frame
  
  // Crear una única luz ambiental para toda la escena
  //ambientLight(20, 20, 20);
  //directionalLight(50, 50, 50, 700, 600, -1);
  
  analyzer.analyze();
  cameraController.update();
  
  translate(-width/2, -height/2, 0);
  updateAndDisplayEnvelopes();
  applyDistortionEffect();
  
  if (showDebugElements) {
    drawDebugElements();
  }
  
  // Añadir la capa de información
  drawHUD();
}

void keyPressed() {
  if (key == 'd' || key == 'D') {
    showDebugElements = !showDebugElements; // Alternar con la tecla D
  }
  
  if (key == 'b' || key == 'B') {
    // Mostrar valores de los beats
    for (int i = 0; i < analyzer.beats.length; i++) {
      println("Beat " + i + ": " + analyzer.beats[i]);
    }
  }
}

void initializeEnvelopes() {
  envelopes = new Envelope[rows][cols];
  
  // Espacio entre sobres
  int spacing = 5;
  
  // Calcular el ancho y alto disponible para cada sobre teniendo en cuenta el espaciado
  float w = (width - (spacing * (cols - 1))) / (float)cols;
  float h = (height - (spacing * (rows - 1))) / (float)rows;
  
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      // Posición ajustada para incluir espaciado
      float x = j * (w + spacing);
      float y = i * (h + spacing);
      
      envelopes[i][j] = new Envelope(x, y, w, h, palette);
    }
  }
}

void updateAndDisplayEnvelopes() {
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      // IMPORTANTE: Asegurarnos de no desbordar el array
      int beatIndex = j % analyzer.beats.length;
      float audioLevel = analyzer.beats[beatIndex];
      
      // Para debugging, podemos aumentar temporalmente el nivel para columnas específicas
      // if (j == 5) audioLevel *= 1.5; // Amplificar la columna 5
      
      envelopes[i][j].update(audioLevel);
      envelopes[i][j].display();
    }
  }
}

void applyDistortionEffect() {
  // Efecto de distorsión basado en los niveles de beats
  float totalEnergy = 0;
  for (float level : analyzer.beats) {
    totalEnergy += level;
  }
  
  totalEnergy /= cols; // Normalizar por número de columnas (beats)
  
  // Aplicar distorsión visual basada en la energía de audio
  if (totalEnergy > 0.4) {
    filter(BLUR, map(totalEnergy, 0.4, 1.0, 1, 3));
  }
}

void drawHUD() {
  // Restaurar la cámara para dibujar la interfaz en 2D
  cam.beginHUD();
  
  fill(255);
  textAlign(LEFT, TOP);
  textSize(14);
  
  // Información del sobre actualmente seleccionado (el que tiene mayor openness)
  int maxRow = 0;
  int maxCol = 0;
  float maxOpenness = 0;
  
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      if (envelopes[i][j].openness > maxOpenness) {
        maxOpenness = envelopes[i][j].openness;
        maxRow = i;
        maxCol = j;
      }
    }
  }
  
  // Mostrar información del sobre seleccionado
  String envelopeInfo = String.format("Sobre seleccionado: X=%d, Y=%d, Apertura=%.2f", 
                                     maxCol, maxRow, maxOpenness);
  text(envelopeInfo, 20, 20);
  
  // Mostrar información de la cámara
  String cameraInfo = String.format("Cámara: Rotación=%.2f, %.2f, %.2f", 
                                   cameraController.currentPosition.x,
                                   cameraController.currentPosition.y,
                                   cameraController.currentPosition.z);
  text(cameraInfo, 20, 40);
  
  // Mostrar objetivo de la cámara
  String targetInfo = String.format("Objetivo: Rotación=%.2f, %.2f, %.2f", 
                                   cameraController.targetPosition.x,
                                   cameraController.targetPosition.y,
                                   cameraController.targetPosition.z);
  text(targetInfo, 20, 60);
  
  // Mostrar SOLO información de los sobres activos
  text("Sobres activos:", 20, 80);
  
  int count = 0;
  int yPos = 100;
  int activosTotal = 0;
  
  // Primero contar cuántos sobres activos hay
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      if (envelopes[i][j].openness > 0) {
        activosTotal++;
      }
    }
  }
  
  // Mostrar solo los activos
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      if (envelopes[i][j].openness > 0) {
        // Posición real del sobre en pantalla
        float posX = envelopes[i][j].position.x;
        float posY = envelopes[i][j].position.y;
        
        String info = String.format("Sobre [%d,%d]: Pos=(%.0f,%.0f), Apertura=%.2f", 
                                   j, i, posX, posY, envelopes[i][j].openness);
        
        fill(255, 255, 100); // Color amarillo para sobres activos
        text(info, 20, yPos);
        yPos += 16;
        count++;
        
        // Evitar que la lista se salga de la pantalla
        if (yPos > height - 40) {
          break;
        }
      }
    }
    if (yPos > height - 40) break;
  }
  
  // Indicación de total de sobres activos
  fill(255);
  text("Mostrando " + count + " de " + activosTotal + " sobres activos (Total: " + (rows * cols) + ")", 20, yPos + 10);
  
  // Agregar información del modo de depuración
  if (showDebugElements) {
    fill(255, 0, 0);
    text("MODO DEPURACIÓN ACTIVO", width - 250, 20);
  }
  
  cam.endHUD();
}

void drawDebugElements() {
  // Restaurar transformaciones para dibujar elementos de depuración
  pushMatrix();
  
  fill(255);
  textSize(12);
  textAlign(CENTER);
  
  // Dibuja representaciones de las luces
  // Luz ambiental (como esfera central)
  stroke(20, 20, 255); // Azul para luz ambiental
  fill(20, 20, 255, 100);
  pushMatrix();
  translate(width/2, height/2, 0);
  sphere(30);
  // Etiqueta para la luz ambiental
  fill(255);
  text("Luz Ambiental", 0, 50);
  popMatrix();
  
  // Luz direccional (como flecha)
  stroke(255, 255, 0); // Amarillo para luz direccional
  fill(255, 255, 0, 100);
  pushMatrix();
  translate(width/2, 100, 200); // Posición aproximada de la luz
  // Dibujar una flecha apuntando en dirección 0, 0, -1
  line(0, 0, 0, 0, 0, -100);
  cone(10, 20); // Punta de flecha
  // Etiqueta para la luz direccional
  fill(255);
  text("Luz Direccional", 0, 30);
  popMatrix();
  
  // Dibuja ejes de coordenadas
  pushMatrix();
  translate(0, 0, 0);
  // Eje X en rojo
  stroke(255, 0, 0); 
  line(0, 0, 0, 100, 0, 0);
  fill(255, 0, 0);
  text("Eje X", 110, 0);
  
  // Eje Y en verde
  stroke(0, 255, 0);
  line(0, 0, 0, 0, 100, 0);
  fill(0, 255, 0);
  text("Eje Y", 0, 110);
  
  // Eje Z en azul
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 100);
  fill(0, 0, 255);
  text("Eje Z", 0, 0, 110);
  
  // Etiqueta para el origen
  fill(255);
  text("Origen (0,0,0)", 0, -20);
  popMatrix();
  
  // Visualización simple de la cámara
  stroke(255);
  noFill();
  pushMatrix();
  // Posición aproximada de la cámara
  translate(cameraController.currentPosition.x, 
            cameraController.currentPosition.y, 
            cameraController.currentPosition.z);
  box(20);
  // Etiqueta de la cámara
  fill(255);
  text("Cámara", 0, -30);
  
  // Dibujar línea hacia donde mira
  stroke(255, 150, 0);
  line(0, 0, 0, 
       cameraController.targetPosition.x - cameraController.currentPosition.x,
       cameraController.targetPosition.y - cameraController.currentPosition.y, 
       cameraController.targetPosition.z - cameraController.currentPosition.z);
  popMatrix();
  
  // Etiqueta para el punto objetivo
  pushMatrix();
  translate(cameraController.targetPosition.x, 
            cameraController.targetPosition.y, 
            cameraController.targetPosition.z);
  fill(255, 150, 0);
  text("Objetivo", 0, -15);
  stroke(255, 150, 0);
  noFill();
  sphere(10);
  popMatrix();
  
  // Información sobre sobres activos
  int sobresActivos = 0;
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      if (envelopes[i][j].openness > 0) {
        sobresActivos++;
      }
    }
  }
  
  pushMatrix();
  translate(width/2, height - 50, 0);
  fill(255);
  textSize(14);
  text("Sobres activos: " + sobresActivos + " / " + (rows * cols), 0, 0);
  popMatrix();
  
  popMatrix();
}

// Función auxiliar para dibujar un cono (punta de flecha)
void cone(float radius, float h) {
  pushMatrix();
  rotateX(PI); // Orientar el cono correctamente
  float sides = 8;
  float angle = 0;
  float angleIncrement = TWO_PI / sides;
  beginShape(TRIANGLE_FAN);
  vertex(0, 0, h); // Punta del cono
  for (int i = 0; i <= sides; i++) {
    vertex(cos(angle) * radius, sin(angle) * radius, 0);
    angle += angleIncrement;
  }
  endShape();
  popMatrix();
}
