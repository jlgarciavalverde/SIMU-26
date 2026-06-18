// ============================================================
//  CLASE: MariposaRuido
//  TIPO DE MOVIMIENTO: NOISE (Perlin noise)
//
//  Una gran mariposa mágica cuya trayectoria está determinada
//  íntegramente por la función noise() de Processing,
//  produciendo un vuelo orgánico e impredecible.
// ============================================================
class MariposaRuido {
  PVector posicion;
  float   tX, tY;       // offsets de tiempo en el espacio de ruido
  float   velocidad;
  float   anguloAlas;
  // Estela: historial de posiciones
  int     largoEstela;
  float[] estelaX, estelaY;
  color   colorCuerpo;

  MariposaRuido() {
    posicion    = new PVector(random(100, width - 100), random(80, height - 150));
    tX          = random(1000);
    tY          = random(1000);
    velocidad   = 2.5;
    largoEstela = 30;
    estelaX     = new float[largoEstela];
    estelaY     = new float[largoEstela];
    anguloAlas  = 0;
    colorCuerpo = color(220, 140, 255);  // violeta mágico

    for (int i = 0; i < largoEstela; i++) {
      estelaX[i] = posicion.x;
      estelaY[i] = posicion.y;
    }
  }

  /** La posición se actualiza mediante ruido de Perlin en dos ejes. */
  void actualizar() {
    // Mappear noise(0..1) a un rango de velocidad (-vel, +vel)
    float vx = map(noise(tX), 0, 1, -velocidad, velocidad);
    float vy = map(noise(tY), 0, 1, -velocidad, velocidad);

    // Avanzar offsets de tiempo para obtener movimiento continuo
    tX += 0.007;
    tY += 0.007;

    // Actualizar estela
    for (int i = largoEstela - 1; i > 0; i--) {
      estelaX[i] = estelaX[i - 1];
      estelaY[i] = estelaY[i - 1];
    }
    estelaX[0] = posicion.x;
    estelaY[0] = posicion.y;

    posicion.x += vx;
    posicion.y += vy;

    // Mantener dentro del escenario con rebote suave
    if (posicion.x < 30)           { posicion.x = 30;           tX += 0.5; }
    if (posicion.x > width - 30)   { posicion.x = width - 30;   tX += 0.5; }
    if (posicion.y < 40)           { posicion.y = 40;            tY += 0.5; }
    if (posicion.y > height - 120) { posicion.y = height - 120;  tY += 0.5; }

    anguloAlas = sin(frameCount * 0.18) * 0.7;
  }

  /** Dibuja la estela mágica y la mariposa. */
  void dibujar() {
    // Estela de polvo mágico
    noFill();
    for (int i = 1; i < largoEstela; i++) {
      float alpha = map(i, 0, largoEstela, 160, 0);
      stroke(red(colorCuerpo), green(colorCuerpo), blue(colorCuerpo), alpha);
      strokeWeight(map(i, 0, largoEstela, 3, 0.3));
      line(estelaX[i-1], estelaY[i-1], estelaX[i], estelaY[i]);
    }
    noStroke();

    // --- Cuerpo de la mariposa ---
    pushMatrix();
    translate(posicion.x, posicion.y);

    // Alas (más grandes que MariposaS — es la "mariposa reina")
    // Ala superior izquierda
    pushMatrix();
    rotate(-anguloAlas);
    fill(220, 140, 255, 210);
    ellipse(-16, -8, 36, 22);
    fill(180, 90, 255, 140);
    ellipse(-18, -5, 22, 12);
    popMatrix();

    // Ala superior derecha
    pushMatrix();
    rotate(anguloAlas);
    fill(220, 140, 255, 210);
    ellipse(16, -8, 36, 22);
    fill(180, 90, 255, 140);
    ellipse(18, -5, 22, 12);
    popMatrix();

    // Ala inferior izquierda
    pushMatrix();
    rotate(-anguloAlas * 0.6);
    fill(200, 100, 255, 170);
    ellipse(-12, 6, 24, 16);
    popMatrix();

    // Ala inferior derecha
    pushMatrix();
    rotate(anguloAlas * 0.6);
    fill(200, 100, 255, 170);
    ellipse(12, 6, 24, 16);
    popMatrix();

    // Cuerpo
    fill(60, 20, 80);
    ellipse(0, 0, 8, 18);

    // Cabeza
    fill(80, 30, 100);
    ellipse(0, -11, 8, 8);

    // Antenas con brillo
    stroke(200, 120, 255, 180);
    strokeWeight(1.2);
    line(0, -15, -8, -22);
    line(0, -15,  8, -22);
    fill(255, 200, 255);
    noStroke();
    ellipse(-8, -22, 4, 4);
    ellipse( 8, -22, 4, 4);

    popMatrix();
  }
}
