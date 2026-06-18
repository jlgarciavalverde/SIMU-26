// ============================================================
//  BOSQUE ENCANTADO – Escenario interactivo
//  Asignatura: Simulación
//  Autor: José Luis García Valverde — Grupo 1.1 (jl.garciavalverde@um.es)
//  Fecha: Marzo 2026
// ============================================================
//
//  CÓMO INTERACTUAR:
//  - Haz clic en cualquier lugar para crear una explosión de luciérnagas.
//  - Mueve el ratón para atraer a las Mariposas Sinusoidales.
//  - Pulsa la tecla [D] para activar/desactivar el "modo día".
//  - Pulsa la tecla [R] para reiniciar todas las criaturas.
//
// ============================================================

// --- Variables globales ---
SistemaBrillo   sistemaBrillo;      // Sistema de partículas (luciérnagas)
Sierpe          sierpe;             // Movimiento RECTILÍNEO (serpiente)
MariposaRuido   mariposa;           // Movimiento por RUIDO (noise)
ArrayList<MariposaS>  mariposas;    // Movimiento SINUSOIDAL (bandada)
ArrayList<Flor>       flores;       // Movimiento de GIRO (rotación)

boolean modoDia  = false;           // Estado del "modo día"
float   transDia = 0;               // 0 = noche pura, 1 = día pleno (transición suave)

// Datos de la hierba (pre-generados para animar el ondeo cada frame)
float[] hierba_x;
float[] hierba_h;

// Paleta del fondo
color CIELO_NOCHE  = color(10,  10,  35);
color CIELO_DIA    = color(100, 170, 255);
color SUELO_COLOR  = color(18,  55,  18);
color NIEBLA_COLOR = color(30,  60,  30, 80);

// ============================================================
void setup() {
  size(900, 600);
  colorMode(RGB, 255);

  sistemaBrillo = new SistemaBrillo(200);   // 200 luciérnagas
  sierpe        = new Sierpe();

  // Pre-generar posiciones y alturas de cada brizna de hierba
  int numBriznas = width / 5;
  hierba_x = new float[numBriznas];
  hierba_h = new float[numBriznas];
  randomSeed(7);
  for (int i = 0; i < numBriznas; i++) {
    hierba_x[i] = i * 5.0;
    hierba_h[i] = random(5, 18);
  }
  randomSeed(millis());
  mariposa      = new MariposaRuido();

  // Bandada de mariposas sinusoidales
  mariposas = new ArrayList<MariposaS>();
  for (int i = 0; i < 8; i++) {
    mariposas.add(new MariposaS(random(width), random(100, height - 100)));
  }

  // Flores giratorias distribuidas por el suelo
  flores = new ArrayList<Flor>();
  for (int i = 0; i < 12; i++) {
    flores.add(new Flor(random(40, width - 40), random(height - 90, height - 30)));
  }
}

// ============================================================
void draw() {
  // Transición suave entre noche y día (~1.5 s para completarse)
  transDia = lerp(transDia, modoDia ? 1.0 : 0.0, 0.02);

  // --- Capas de dibujo (de atrás hacia adelante) ---

  // 1. Cielo, suelo y hierba
  dibujarFondo();

  // 2. Árboles del fondo (plano lejano)
  dibujarArbolesLejanos();

  // 3. Niebla del suelo
  dibujarNiebla();

  // 4. Flores giratorias en el suelo (ROTACIÓN)
  for (Flor f : flores) {
    f.actualizar();
    f.dibujar();
  }

  // 5. Sierpe en el suelo (MOVIMIENTO RECTILÍNEO)
  sierpe.actualizar();
  sierpe.dibujar();

  // 6. Árboles de primer plano — tapan parcialmente lo del suelo
  dibujarArbolesCercanos();

  // 7. Mariposas sinusoidales volando (SENO)
  for (MariposaS ms : mariposas) {
    ms.actualizar();
    ms.dibujar();
  }

  // 8. Mariposa de ruido volando (NOISE)
  mariposa.actualizar();
  mariposa.dibujar();

  // 9. Sistema de partículas: luciérnagas
  sistemaBrillo.actualizar();
  sistemaBrillo.dibujar();

  // 10. HUD con instrucciones
  dibujarHUD();
}

// ============================================================
// Eventos de teclado y ratón
// ============================================================
void mousePressed() {
  // Explosión de luciérnagas en el punto de clic
  sistemaBrillo.explotar(mouseX, mouseY, 30);
}

void keyPressed() {
  if (key == 'd' || key == 'D') {
    modoDia = !modoDia;
  }
  if (key == 'r' || key == 'R') {
    sierpe        = new Sierpe();
    mariposa      = new MariposaRuido();
    mariposas.clear();
    for (int i = 0; i < 8; i++) {
      mariposas.add(new MariposaS(random(width), random(100, height - 100)));
    }
  }
}

// ============================================================
// Funciones auxiliares de dibujo del escenario
// ============================================================

/** Dibuja el gradiente de cielo y el suelo con transición suave día/noche. */
void dibujarFondo() {
  // Colores del cielo interpolados con transDia
  color cieloTop = lerpColor(CIELO_NOCHE,       color(100, 170, 255), transDia);
  color cieloBot = lerpColor(color(20, 30, 60), color(180, 230, 255), transDia);

  // Gradiente vertical del cielo
  noFill();
  for (int y = 0; y < height - 100; y++) {
    float t = map(y, 0, height - 100, 0, 1);
    stroke(lerpColor(cieloTop, cieloBot, t));
    line(0, y, width, y);
  }
  noStroke();

  // --- LUNA (se desvanece al amanecer) ---
  float alfaNoche = 1 - transDia;
  if (alfaNoche > 0.02) {
    // Aura difusa en capas
    for (int r = 90; r > 28; r -= 6) {
      float a = map(r, 28, 90, 50, 0) * alfaNoche;
      fill(180, 200, 255, (int)a);
      ellipse(750, 70, r, r);
    }
    // Disco lunar
    fill(255, 255, 220, (int)(210 * alfaNoche));
    ellipse(750, 70, 55, 55);
    // "Mordisco" cuyo color sigue el cielo actual
    fill(red(cieloTop), green(cieloTop), blue(cieloTop), (int)(255 * alfaNoche));
    ellipse(768, 63, 55, 55);
  }

  // --- ESTRELLAS parpadeantes (se desvanecen al amanecer) ---
  if (alfaNoche > 0.02) {
    randomSeed(42);
    for (int i = 0; i < 80; i++) {
      float sx = random(width);
      float sy = random(height - 200);
      float sr = random(0.5, 2.2);
      // Parpadeo orgánico con noise()
      float brillo = noise(sx * 0.04, sy * 0.04, frameCount * 0.012);
      float alpha  = map(brillo, 0, 1, 40, 220) * alfaNoche;
      fill(255, 255, 200, alpha);
      ellipse(sx, sy, sr * 2, sr * 2);
    }
    randomSeed(millis());
  }

  // --- SOL (aparece al amanecer) ---
  if (transDia > 0.02) {
    // Halo solar
    for (int r = 130; r > 40; r -= 8) {
      float a = map(r, 40, 130, 55, 0) * transDia;
      fill(255, 230, 80, (int)a);
      ellipse(750, 80, r, r);
    }
    // Disco solar
    fill(255, 220, 50, (int)(255 * transDia));
    ellipse(750, 80, 70, 70);
    // Rayos que giran lentamente
    stroke(255, 220, 50, (int)(140 * transDia));
    strokeWeight(2);
    float rotSol = frameCount * 0.004;
    for (int a = 0; a < 12; a++) {
      float ang = TWO_PI / 12 * a + rotSol;
      line(750 + cos(ang)*40, 80 + sin(ang)*40,
           750 + cos(ang)*58, 80 + sin(ang)*58);
    }
    strokeWeight(1);
    noStroke();
  }

  // --- SUELO (más claro y verde de día) ---
  color sueloDia = color(35, 100, 35);
  fill(lerpColor(SUELO_COLOR, sueloDia, transDia));
  noStroke();
  rect(0, height - 100, width, 100);

  // --- HIERBA ANIMADA (ondeo senoidal según el "viento") ---
  color hierbaDia   = color(55, 160, 55);
  color hierbaNoche = color(30,  90, 30);
  stroke(lerpColor(hierbaNoche, hierbaDia, transDia));
  strokeWeight(1);
  for (int i = 0; i < hierba_x.length; i++) {
    float ondeo = sin(frameCount * 0.04 + hierba_x[i] * 0.07) * 3.5;
    line(hierba_x[i], height - 100,
         hierba_x[i] + ondeo, height - 100 - hierba_h[i]);
  }
  strokeWeight(1);
  noStroke();
}

/** Dibuja los árboles del fondo (plano lejano, más pequeños y claros). */
void dibujarArbolesLejanos() {
  dibujarArbol(80,  height - 100, 20, 110, color(15, 35, 15), color(35, 90, 35));
  dibujarArbol(200, height - 100, 18, 95,  color(15, 35, 15), color(35, 90, 35));
  dibujarArbol(430, height - 100, 22, 120, color(15, 35, 15), color(35, 90, 35));
  dibujarArbol(640, height - 100, 19, 100, color(15, 35, 15), color(35, 90, 35));
  dibujarArbol(810, height - 100, 21, 115, color(15, 35, 15), color(35, 90, 35));
}

/** Dibuja los árboles de primer plano (más grandes y oscuros, tapan a las criaturas del suelo). */
void dibujarArbolesCercanos() {
  dibujarArbol(0,   height - 90, 30, 160, color(8, 20, 8), color(22, 65, 22));
  dibujarArbol(140, height - 90, 28, 145, color(8, 20, 8), color(22, 65, 22));
  dibujarArbol(350, height - 90, 32, 170, color(8, 20, 8), color(22, 65, 22));
  dibujarArbol(570, height - 90, 27, 150, color(8, 20, 8), color(22, 65, 22));
  dibujarArbol(760, height - 90, 31, 165, color(8, 20, 8), color(22, 65, 22));
  dibujarArbol(880, height - 90, 25, 140, color(8, 20, 8), color(22, 65, 22));
}

/** Dibuja un árbol genérico en (x,y) con grosor de tronco w y altura h. */
void dibujarArbol(float x, float y, float w, float h, color cNoche, color cDia) {
  color c = lerpColor(cNoche, cDia, transDia);
  noStroke();
  fill(c);
  // Tronco
  rect(x - w/2, y - h * 0.3, w, h * 0.3);
  // Copa triangular (tres triángulos escalonados)
  triangle(x - w*2.5, y - h*0.35,
           x + w*2.5, y - h*0.35,
           x,         y - h);
  triangle(x - w*2.0, y - h*0.55,
           x + w*2.0, y - h*0.55,
           x,         y - h * 1.15);
  triangle(x - w*1.4, y - h*0.72,
           x + w*1.4, y - h*0.72,
           x,         y - h * 1.28);
}

/** Dibuja una capa de niebla/ambiente en el suelo, adaptada al momento del día. */
void dibujarNiebla() {
  noStroke();
  // De noche: neblina verde oscura. De día: neblina verde clara casi blanca.
  color niebla = lerpColor(NIEBLA_COLOR, color(200, 230, 200, 60), transDia);
  for (int y = height - 115; y < height - 75; y++) {
    float alpha = map(y, height - 115, height - 75, 80, 0);
    fill(red(niebla), green(niebla), blue(niebla), alpha);
    rect(0, y, width, 1);
  }
}

/** Muestra las instrucciones en pantalla con estética de bosque. */
void dibujarHUD() {
  // Fondo oscuro translúcido con borde verde mágico
  fill(0, 15, 5, 175);
  stroke(60, 180, 80, 200);
  strokeWeight(1);
  rect(8, 8, 320, 86, 8);
  noStroke();
  // Título
  fill(100, 240, 130);
  textSize(11);
  textAlign(LEFT, TOP);
  text("~ BOSQUE ENCANTADO ~", 18, 13);
  // Instrucciones
  fill(180, 255, 195, 230);
  text("[ CLIC ]    explosion de luciernagas", 18, 29);
  text("[ RATON ]  atrae a las mariposas",      18, 43);
  text("[  D  ]    cambiar dia / noche",         18, 57);
  text("[  R  ]    reiniciar criaturas",          18, 71);
}
