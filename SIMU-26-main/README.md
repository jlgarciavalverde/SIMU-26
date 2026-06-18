# Bosque Encantado — Documentación

**Asignatura:** Simulación
**Práctica:** 1 — Creación de un escenario interactivo
**Autor:** José Luis García Valverde — Grupo 1.1 (jl.garciavalverde@um.es)
**Fecha:** Marzo 2026

---

## Descripción del escenario

*Bosque Encantado* es un escenario nocturno (con transición a día) habitado por criaturas mágicas: una sierpe que recorre el suelo, mariposas que vuelan en bandada, una mariposa reina de vuelo errático, flores que giran en el suelo y luciérnagas que flotan en el aire. El usuario puede interactuar con las criaturas y con la iluminación del escenario en tiempo real.

---

## Controles

| Acción | Efecto |
|--------|--------|
| `Clic` en cualquier punto | Explosión de luciérnagas en ese punto |
| Mover el `ratón` | Atrae a las mariposas sinusoidales |
| Tecla `D` | Alterna entre modo día y modo noche |
| Tecla `R` | Reinicia todas las criaturas |

Las instrucciones son siempre visibles en el HUD (esquina superior izquierda), sin necesidad de consultar el código.

---

## Diagrama de clases

```
BosqueEncantado (programa principal)
│
├── Sierpe                  — movimiento rectilíneo
├── MariposaRuido           — movimiento por ruido de Perlin
├── ArrayList<MariposaS>    — movimiento sinusoidal (8 instancias)
├── ArrayList<Flor>         — movimiento de giro/rotación (12 instancias)
└── SistemaBrillo           — sistema de partículas
      └── ArrayList<Luciernaga>
```

```
┌─────────────────────────────────────────────────────────────────┐
│                      BosqueEncantado                            │
│  - sistemaBrillo : SistemaBrillo                               │
│  - sierpe        : Sierpe                                       │
│  - mariposa      : MariposaRuido                               │
│  - mariposas     : ArrayList<MariposaS>                        │
│  - flores        : ArrayList<Flor>                             │
│  - modoDia       : boolean                                      │
│  - transDia      : float  [0=noche, 1=día]                     │
│  + setup()                                                      │
│  + draw()                                                       │
│  + mousePressed()                                               │
│  + keyPressed()                                                 │
└─────────────────────────────────────────────────────────────────┘
        │           │           │           │           │
        ▼           ▼           ▼           ▼           ▼
┌──────────┐ ┌───────────────┐ ┌─────────┐ ┌────────┐ ┌──────────────────┐
│  Sierpe  │ │ MariposaRuido │ │Mariposa │ │  Flor  │ │  SistemaBrillo   │
│          │ │               │ │    S    │ │        │ │                  │
│-posicion │ │-posicion      │ │-posicion│ │-posicion│ │-particulas       │
│-velocidad│ │-tX, tY        │ │-baseY   │ │-angulo  │ │-cantidadBase     │
│-histX[]  │ │-largoEstela   │ │-amplitud│ │-velGiro │ │                  │
│-histY[]  │ │-estelaX[]     │ │-frec.   │ │-numPet. │ │+actualizar()     │
│-radio    │ │-estelaY[]     │ │-fase    │ │-escala  │ │+dibujar()        │
│          │ │               │ │-velX    │ │         │ │+explotar(x,y,n)  │
│+actual.()│ │+actualizar()  │ │         │ │+actual. │ └──────┬───────────┘
│+dibujar()│ │+dibujar()     │ │+actual. │ │+dibujar │        │
└──────────┘ └───────────────┘ │+dibujar │ └────────┘        ▼
                                └─────────┘          ┌─────────────────┐
                                                      │   Luciernaga    │
                                                      │                 │
                                                      │-posicion        │
                                                      │-velocidad       │
                                                      │-vida, vidaMax   │
                                                      │-radio           │
                                                      │                 │
                                                      │+actualizar()    │
                                                      │+dibujar()       │
                                                      │+estaMuerta()    │
                                                      └─────────────────┘
```

---

## Tipos de movimiento implementados

### 1. Rectilíneo — `Sierpe`
La serpiente se desplaza con velocidad constante en dirección diagonal (componente X e Y fijas). Al llegar a un borde, invierte la componente correspondiente (rebote). El cuerpo es una cadena de 14 segmentos que sigue el historial de posiciones de la cabeza.

### 2. Sinusoidal — `MariposaS`
Cada mariposa avanza horizontalmente a velocidad constante mientras su posición Y oscila según:

```
posicion.y = posicionBaseY + sin(frameCount × frecuencia + fase) × amplitud
```

Cada mariposa tiene `amplitud`, `frecuencia` y `fase` propias (generadas aleatoriamente), lo que produce una bandada visualmente variada. La `posicionBaseY` se desplaza suavemente hacia el ratón cuando este está a menos de 150 px.

### 3. Ruido de Perlin — `MariposaRuido`
La velocidad en X e Y se calcula cada frame mapeando `noise(t)` al intervalo `[-vel, +vel]`. Los offsets `tX` y `tY` avanzan de forma independiente, produciendo un vuelo orgánico e impredecible. Deja una estela de 30 posiciones que se dibuja con opacidad decreciente.

### 4. Giro / Rotación — `Flor`
Cada flor acumula un ángulo de rotación (`angulo += velocidadGiro`) aplicado con `rotate()` antes de dibujar los pétalos. Adicionalmente, la escala pulsa con `sin()` para dar sensación de "respiración":

```
escala = 1 + sin(frameCount × 0.05 + posicion.x) × 0.12
```

### 5. Sistema de partículas — `SistemaBrillo` + `Luciernaga`
`SistemaBrillo` mantiene un pool de 200 luciérnagas ambientales. Cada partícula tiene vida limitada y se reemplaza automáticamente al morir. Al hacer clic se generan 30 partículas adicionales de explosión con velocidad radial aleatoria. La opacidad de cada luciérnaga se atenúa con `transDia` para desvanecerse al amanecer.

---

## Decisiones de diseño

### Estructura en ficheros separados
Cada clase ocupa su propio fichero `.pde`. Processing trata todos los ficheros de la carpeta como un único sketch, por lo que esta organización no afecta al funcionamiento pero mejora la legibilidad y el mantenimiento.

### Transición día/noche con `lerp`
En lugar de un cambio brusco, `transDia` se interpola suavemente cada frame (`lerp(..., 0.02)`). Esta variable global es leída por el fondo, los árboles, la hierba, la niebla y las luciérnagas para que toda la escena cambie de forma coherente.

### Capas de dibujo (z-order)
El orden de dibujo en `draw()` define la profundidad visual:

```
Cielo + suelo → Árboles lejanos → Niebla → Flores → Sierpe
→ Árboles cercanos → Mariposas → Luciérnagas → HUD
```

Los árboles de primer plano se dibujan después de las criaturas del suelo (sierpe, flores) para que estas queden parcialmente ocultas, creando sensación de profundidad.

### Generación procedural del escenario
El fondo se dibuja íntegramente con primitivas de Processing: gradiente línea a línea para el cielo, rectángulos para el suelo, triángulos apilados para los árboles, y líneas con desplazamiento sinusoidal para la hierba animada. No se usan imágenes para el escenario.

### Interactividad con `posicionBaseY` en `MariposaS`
La atracción al ratón modifica `posicionBaseY` (el centro de la onda) en lugar de `posicion.y` directamente. Así la onda sinusoidal se preserva durante el movimiento hacia el cursor, sin que la trayectoria se rompa ni acumule deriva.

### Pool de partículas sin límite estricto
`SistemaBrillo` distingue entre partículas ambientales (regeneradas para mantener siempre ~200) y partículas de explosión (temporales). Las explosiones se añaden al `ArrayList` y desaparecen solas al agotar su vida, sin necesidad de gestión adicional.

---

## Estructura de ficheros

```
BosqueEncantado/
├── BosqueEncantado.pde   — setup(), draw(), eventos, funciones de dibujo del escenario
├── Sierpe.pde            — clase Sierpe (movimiento rectilíneo)
├── MariposaRuido.pde     — clase MariposaRuido (ruido de Perlin)
├── MariposaS.pde         — clase MariposaS (movimiento sinusoidal)
├── Flor.pde              — clase Flor (rotación / giro)
└── SistemaBrillo.pde     — clases Luciernaga y SistemaBrillo (partículas)
```
