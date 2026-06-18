// ============================================================
//  CLASE: MariposaS
//  TIPO DE MOVIMIENTO: SINUSOIDAL
//
//  Mariposa que avanza horizontalmente mientras oscila en Y
//  siguiendo una onda senoidal. Se ve atraída hacia el ratón.
// ============================================================
class MariposaS {
  PVector posicion;
  float   posicionBaseY; // centro de la oscilación sinusoidal en Y
  float   velocidadX;   // velocidad horizontal constante
  float   amplitud;     // amplitud de la onda
  float   frecuencia;   // frecuencia de la onda
  float   fase;         // desfase individual
  float   anguloAlas;   // para animar las alas
  color   colorCuerpo;

  MariposaS(float x, float y) {
    posicion      = new PVector(x, y);
    posicionBaseY = y;
    velocidadX    = random(0.8, 2.2) * (random(1) > 0.5 ? 1 : -1);
    amplitud      = random(15, 40);
    frecuencia    = random(0.02, 0.05);
    fase          = random(TWO_PI);
    anguloAlas    = 0;
    colorCuerpo   = color(random(100,180), random(150,255), random(200,255));
  }

  /** Actualiza la posición con movimiento sinusoidal + atracción suave al ratón. */
  void actualizar() {
    // Movimiento horizontal
    posicion.x += velocidadX;

    // Componente vertical sinusoidal pura: posición absoluta desde la base
    posicion.y = posicionBaseY + sin(frameCount * frecuencia + fase) * amplitud;

    // Atracción suave hacia el ratón: se desplaza la BASE de la oscilación
    float dx = mouseX - posicion.x;
    float dy = mouseY - posicionBaseY;
    float distRaton = sqrt(dx * dx + dy * dy);
    if (distRaton < 150) {
      posicion.x    += dx * 0.01;
      posicionBaseY += dy * 0.01;
    }

    // Rebotes en los bordes
    if (posicion.x < 20 || posicion.x > width - 20)  velocidadX *= -1;
    posicionBaseY = constrain(posicionBaseY, 40 + amplitud, height - 120 - amplitud);

    // Animación de alas
    anguloAlas = sin(frameCount * 0.25) * 0.6;
  }

  /** Dibuja la mariposa como dos elipses (alas) y un óvalo central (cuerpo). */
  void dibujar() {
    pushMatrix();
    translate(posicion.x, posicion.y);

    // Las alas se "abren y cierran" con rotación
    noStroke();

    // Ala izquierda
    pushMatrix();
    rotate(-anguloAlas);
    fill(red(colorCuerpo), green(colorCuerpo), blue(colorCuerpo), 200);
    ellipse(-10, -4, 22, 14);
    // Detalle ala
    fill(red(colorCuerpo)*0.6, green(colorCuerpo)*0.6, blue(colorCuerpo)*0.6, 150);
    ellipse(-11, 2, 16, 8);
    popMatrix();

    // Ala derecha
    pushMatrix();
    rotate(anguloAlas);
    fill(red(colorCuerpo), green(colorCuerpo), blue(colorCuerpo), 200);
    ellipse(10, -4, 22, 14);
    fill(red(colorCuerpo)*0.6, green(colorCuerpo)*0.6, blue(colorCuerpo)*0.6, 150);
    ellipse(11, 2, 16, 8);
    popMatrix();

    // Cuerpo
    fill(30, 20, 40);
    ellipse(0, 0, 6, 14);

    // Antenas
    stroke(80, 60, 80);
    strokeWeight(1);
    line(0, -7, -6, -14);
    line(0, -7,  6, -14);
    fill(red(colorCuerpo), green(colorCuerpo), blue(colorCuerpo));
    noStroke();
    ellipse(-6, -14, 3, 3);
    ellipse( 6, -14, 3, 3);

    popMatrix();
  }
}
