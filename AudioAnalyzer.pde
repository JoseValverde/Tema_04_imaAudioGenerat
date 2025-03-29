class AudioAnalyzer {
  FFT fft;
  SoundFile audio;
  float[] beats;
  
  AudioAnalyzer(PApplet parent, String filename) {
    audio = new SoundFile(parent, filename);
    audio.loop();
    
    fft = new FFT(parent);
    fft.input(audio);
    
    // Crear exactamente 10 slots para beats (uno por columna)
    beats = new float[10];
  }
  
  void analyze() {
    fft.analyze();
    
    // Calcular beats para las 10 columnas usando diferentes rangos de frecuencia
    for (int i = 0; i < 10; i++) {
      beats[i] = calculateBeatForColumn(i);
    }
    
    // Debug: imprimir valores para ver qué columnas reciben señal
    if (frameCount % 30 == 0) {
      println("Beats: " + beats[0] + ", " + beats[3] + ", " + beats[6] + ", " + beats[9]);
    }
  }
  
  float calculateBeatForColumn(int column) {
    // Enfoque totalmente nuevo y simplificado
    int spectrumSize = fft.spectrum.length;
    
    // Distribuir el espectro uniformemente entre las columnas
    int segmentSize = spectrumSize / 10; // 10 columnas
    int start = column * segmentSize;
    int end = (column + 1) * segmentSize;
    if (end > spectrumSize) end = spectrumSize;
    
    float sum = 0;
    for (int i = start; i < end; i++) {
      sum += fft.spectrum[i];
    }
    
    // Factores de amplificación enormemente aumentados
    float amplification;
    
    if (column == 0) {
      // Muy bajas frecuencias (0) - bombos y subgraves
      amplification = 100.0;
    } else if (column < 3) {
      // Bajas frecuencias (1-2) - graves y bajos
      amplification = 200.0;
    } else if (column < 6) {
      // Medias frecuencias (3-5) - voces e instrumentos medios
      amplification = 500.0;
    } else {
      // Altas frecuencias (6-9) - hi-hats, cymbals, etc
      amplification = 3000.0; // Amplificación extrema
    }
    
    float avg = (end > start) ? sum / (end - start) : 0;
    float beatValue = avg * sensitivity * amplification;
    
    // Aplicar un límite superior para evitar valores extremos
    return min(beatValue, 1.0);
  }
}
