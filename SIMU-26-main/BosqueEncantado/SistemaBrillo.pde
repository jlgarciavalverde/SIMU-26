// ============================================================
//  CLASE: Luciernaga  (una sola partícula)
//  CLASE: SistemaBrillo  (gestor del sistema de partículas)
// ============================================================

/** Una partícula luminosa que flota en el escenario. */
class Luciernaga {
  PVector posicion;
  PVector velocidad;
  float   vida;        // de 255 hacia 0
  float   vidaMax;
  float   radio;
  color   colorBase;

  // -- Constructor para luciérnagas ambientales --
  Luciernaga() {
    posicion  = new PVector(random(width), random(50, height - 110));
    velocidad = new PVector(random(-0.6, 0.6), random(-0.8, 0.2));
    vidaMax   = random(120, 255);
    vida      = random(vidaMax);
    radio     = random(2, 5);
    colorBase = color(random(180,255), random(220,255), random(50,120));
  }

  // -- Constructor para partículas de explosión --
  Luciernaga(float x, float y) {
    posicion  = new PVector(x, y);
    float angulo = random(TWO_PI);
    float speed  = random(1.5, 5);
    velocidad = new PVector(cos(angulo) * speed, sin(angulo) * speed);
    vidaMax   = random(80, 180);
    vida      = vidaMax;
    radio     = random(3, 7);
    colorBase = color(random(150,255), random(200,255), random(0,100));
  }

  /** Actualiza posición y vida. */
  void actualizar() {
    // Pequeño titileo: la velocidad oscila suavemente
    velocidad.x += random(-0.08, 0.08);
    velocidad.y += random(-0.08, 0.08);
    velocidad.limit(1.2);

    posicion.add(velocidad);

    // Rebote en los bordes
    if (posicion.x < 0 || posicion.x > width)  velocidad.x *= -1;
    if (posicion.y < 50 || posicion.y > height - 110) velocidad.y *= -1;

    vida -= 1.2;
  }

  boolean estaMuerta() {
    return vida <= 0;
  }

  void dibujar() {
    // Las luciérnagas se atenúan cuando sale el sol (usan transDia global)
    float alpha = constrain(vida, 0, 180) * (1 - transDia * 0.88);
    if (alpha < 2) return;  // no dibujar si es casi invisible
    // Halo exterior difuso
    noStroke();
    fill(red(colorBase), green(colorBase), blue(colorBase), alpha * 0.35);
    ellipse(posicion.x, posicion.y, radio * 4, radio * 4);
    // Núcleo brillante
    fill(red(colorBase), green(colorBase), blue(colorBase), alpha);
    ellipse(posicion.x, posicion.y, radio, radio);
  }
}

// ============================================================

/** Gestiona el conjunto de luciérnagas (partículas ambientales + explosiones). */
class SistemaBrillo {
  ArrayList<Luciernaga> particulas;
  int cantidadBase;

  SistemaBrillo(int n) {
    cantidadBase = n;
    particulas   = new ArrayList<Luciernaga>();
    for (int i = 0; i < cantidadBase; i++) {
      particulas.add(new Luciernaga());
    }
  }

  /** Actualiza todas las partículas y reemplaza las muertas por nuevas. */
  void actualizar() {
    for (int i = particulas.size() - 1; i >= 0; i--) {
      Luciernaga l = particulas.get(i);
      l.actualizar();
      if (l.estaMuerta()) {
        particulas.remove(i);
        // Solo regenera si estamos por debajo de la cantidad base
        if (particulas.size() < cantidadBase) {
          particulas.add(new Luciernaga());
        }
      }
    }
  }

  /** Dibuja todas las partículas. */
  void dibujar() {
    for (Luciernaga l : particulas) {
      l.dibujar();
    }
  }

  /**
   * Crea una explosión de 'cantidad' partículas en (x, y).
   * Las partículas extras se añaden temporalmente y desaparecen solas.
   */
  void explotar(float x, float y, int cantidad) {
    for (int i = 0; i < cantidad; i++) {
      particulas.add(new Luciernaga(x, y));
    }
  }
}
