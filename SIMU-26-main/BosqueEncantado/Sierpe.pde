// ============================================================
//  CLASE: Sierpe
//  TIPO DE MOVIMIENTO: RECTILÍNEO (con rebote)
//
//  Una serpiente mágica que se desplaza en línea recta por el
//  suelo del bosque y rebota al llegar a los límites.
// ============================================================
class Sierpe {
  PVector posicion;
  PVector velocidad;    // velocidad constante → movimiento rectilíneo
  int     numSegmentos;
  float[] histX, histY; // historial de posiciones para el cuerpo
  float   radio;
  color   colorCuerpo;

  Sierpe() {
    posicion     = new PVector(random(50, width - 50), height - 80);
    velocidad    = new PVector(random(1.5, 3) * (random(1) > 0.5 ? 1 : -1),
                               random(0.4, 1.0) * (random(1) > 0.5 ? 1 : -1));
    numSegmentos = 14;
    histX        = new float[numSegmentos];
    histY        = new float[numSegmentos];
    radio        = 10;
    colorCuerpo  = color(50, 200, 80);

    // Inicializar historial en la posición actual
    for (int i = 0; i < numSegmentos; i++) {
      histX[i] = posicion.x;
      histY[i] = posicion.y;
    }
  }

  /** Mueve la serpiente en línea recta y rebota en los bordes. */
  void actualizar() {
    // Desplazar historial (cada segmento sigue al anterior)
    for (int i = numSegmentos - 1; i > 0; i--) {
      histX[i] = histX[i - 1];
      histY[i] = histY[i - 1];
    }
    histX[0] = posicion.x;
    histY[0] = posicion.y;

    // Movimiento rectilíneo puro
    posicion.add(velocidad);

    // Rebote en los cuatro bordes (movimiento rectilíneo diagonal)
    if (posicion.x < radio || posicion.x > width - radio) {
      velocidad.x *= -1;
    }
    if (posicion.y < height - 130 || posicion.y > height - 55) {
      velocidad.y *= -1;
    }
  }

  /** Dibuja la serpiente como una cadena de círculos. */
  void dibujar() {
    noStroke();
    for (int i = numSegmentos - 1; i >= 0; i--) {
      float t      = map(i, 0, numSegmentos - 1, 1, 0.3);  // degradado cola→cabeza
      float r      = radio * t;
      float bright = map(i, 0, numSegmentos - 1, 255, 80);
      fill(red(colorCuerpo) * t, bright, 80);
      ellipse(histX[i], histY[i], r * 2, r * 2);
    }

    // Cabeza con ojos
    fill(30, 220, 60);
    ellipse(posicion.x, posicion.y, radio * 2.4, radio * 2.4);
    // Ojos
    fill(255, 60, 60);
    float dirX = (velocidad.x > 0) ? 4 : -4;
    ellipse(posicion.x + dirX,     posicion.y - 3, 4, 4);
    ellipse(posicion.x + dirX * 0.4, posicion.y - 3, 4, 4);
    // Lengua bífida
    stroke(255, 50, 50);
    strokeWeight(1.2);
    float lx = posicion.x + (velocidad.x > 0 ? radio + 2 : -(radio + 2));
    line(posicion.x + (velocidad.x > 0 ? radio : -radio), posicion.y, lx, posicion.y);
    line(lx, posicion.y, lx + (velocidad.x > 0 ? 3 : -3), posicion.y - 3);
    line(lx, posicion.y, lx + (velocidad.x > 0 ? 3 : -3), posicion.y + 3);
    strokeWeight(1);
    noStroke();
  }
}
