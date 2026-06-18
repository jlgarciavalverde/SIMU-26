// ============================================================
//  CLASE: Flor
//  TIPO DE MOVIMIENTO: GIRO (rotación)
//
//  Flor mágica del suelo del bosque cuyo centro gira
//  continuamente y cuyos pétalos oscilan con una rotación
//  adicional. Representa el movimiento de GIRO/ROTACIÓN.
// ============================================================
class Flor {
  PVector posicion;
  float   angulo;         // ángulo de rotación actual
  float   velocidadGiro;  // velocidad angular (rad/frame)
  int     numPetalos;
  float   radioPetalo;
  float   radioNucleo;
  color   colorPetalo;
  color   colorNucleo;
  float   escala;         // para animar el "pulso"

  Flor(float x, float y) {
    posicion      = new PVector(x, y);
    angulo        = random(TWO_PI);
    velocidadGiro = random(0.01, 0.04) * (random(1) > 0.5 ? 1 : -1);
    numPetalos    = int(random(5, 9));
    radioPetalo   = random(8, 18);
    radioNucleo   = radioPetalo * 0.4;
    // Colores mágicos variados
    colorPetalo = color(random(150,255), random(30,120), random(150,255), 200);
    colorNucleo = color(255, random(200,255), 50);
    escala      = 1;
  }

  /** Incrementa el ángulo → rotación continua. Anima el "pulso". */
  void actualizar() {
    angulo += velocidadGiro;
    // Pulso de escala con seno para un efecto "vivo"
    escala = 1 + sin(frameCount * 0.05 + posicion.x) * 0.12;
  }

  /** Dibuja la flor rotada y escalada. */
  void dibujar() {
    pushMatrix();
    translate(posicion.x, posicion.y);
    scale(escala);

    // Tallo
    stroke(40, 120, 40);
    strokeWeight(1.5);
    line(0, 0, 0, 12);
    noStroke();

    // Pétalos (dispuestos en círculo, todos girados por 'angulo')
    rotate(angulo);
    for (int i = 0; i < numPetalos; i++) {
      float theta = map(i, 0, numPetalos, 0, TWO_PI);
      pushMatrix();
      rotate(theta);
      fill(colorPetalo);
      // Cada pétalo es una elipse descentrada
      ellipse(0, -radioPetalo, radioPetalo * 0.75, radioPetalo * 1.3);
      popMatrix();
    }

    // Núcleo brillante
    fill(colorNucleo);
    ellipse(0, 0, radioNucleo * 2, radioNucleo * 2);
    // Brillo central
    fill(255, 255, 200, 200);
    ellipse(0, 0, radioNucleo * 0.7, radioNucleo * 0.7);

    popMatrix();
  }
}
