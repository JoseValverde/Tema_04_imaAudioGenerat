class CameraController {
  float lastChangeTime = 0;
  PVector targetPosition = new PVector();
  PVector currentPosition = new PVector();
  
  CameraController(PApplet parent) {
    cam = new PeasyCam(parent, 400);
    cam.setMinimumDistance(200);
    cam.setMaximumDistance(1000);
  }
  
  void update() {
    if (millis() - lastChangeTime > 10000) {
      changeCamera();
      lastChangeTime = millis();
    }
    
    // Interpolar suavemente la posición actual
    currentPosition.lerp(targetPosition, 0.05);
    cam.setRotations(currentPosition.x, currentPosition.y, currentPosition.z);
  }
  
  void changeCamera() {
    targetPosition = new PVector(
      random(-PI/4, PI/4),
      random(-PI/4, PI/4),
      random(-PI/4, PI/4)
    );
  }
}
