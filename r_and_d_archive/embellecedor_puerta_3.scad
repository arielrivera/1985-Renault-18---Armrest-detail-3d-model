// ============================================================
//  Embellecedor / tapa de puerta (descansabrazos)
//  Renault 18 - pieza decorativa, fondo plano
//  Se pega con cinta doble faz. Modelo parametrico:
//  cambia los valores de abajo y vuelve a exportar el STL.
// ============================================================

/* [Medidas principales - en milimetros] */
LARGO      = 45;    // largo total
ANCHO      = 29;    // ancho total
ESPESOR    = 4;     // espesor total (fondo plano abajo)
AGUJERO_D  = 10;    // diametro del agujero central
AGUJERO_X  = 0;     // corrimiento del agujero en el eje largo (+ hacia la derecha)
AGUJERO_Y  = 0;     // corrimiento del agujero en el eje ancho (+ hacia arriba)

/* [Forma] */
RADIO_ESQ  = 7;     // redondeo de las esquinas del contorno
RADIO_CANTO= 1.2;   // redondeo del canto superior (efecto "almohada")
RADIO_INT  = 0.6;   // redondeo del borde interno, arriba y abajo del hundido
ANCHO_MARCO= 3.0;   // ancho del marco: del filo exterior al inicio del hundido
PROF_HUNDIDO=1.4;   // cuanto se hunde la zona central respecto del marco
                    // (PROF_HUNDIDO tiene que ser mayor que 2 x RADIO_INT)

/* [Calidad] */
$fn = 64;

// ---- contorno normalizado (romboide, simetria de 180 grados) ----
// Deducido de las diagonales medidas: 50 mm (sup.izq -> inf.der)
// y 40 mm (inf.izq -> sup.der), dentro de un rectangulo de 45 x 29 mm.
// Esquinas reales: (-22.5, 10.9) (13.8, 14.5) (22.5, -10.9) (-13.8, -14.5)
// Editar estos puntos cambia la silueta. Van de -0.5 a 0.5.
CONTORNO = [
    [-0.5000,  0.3759],   // esquina superior izquierda
    [-0.3067, -0.5000],   // esquina inferior izquierda
    [ 0.5000, -0.3759],   // esquina inferior derecha
    [ 0.3067,  0.5000]    // esquina superior derecha
];

// Silueta final exacta de LARGO x ANCHO, con las esquinas redondeadas.
module contorno_2d() {
    resize([LARGO, ANCHO])
        offset(r = RADIO_ESQ) offset(r = -RADIO_ESQ)
            scale([LARGO, ANCHO]) polygon(CONTORNO);
}

// La misma silueta metida hacia adentro d mm de forma pareja en todo
// el perimetro (offset real, no un escalado: por eso el marco mide lo
// mismo en los lados largos que en las puntas).
module perfil_2d(d) {
    offset(r = -d) contorno_2d();
}

module semiesfera(r) {
    intersection() {
        sphere(r = r);
        translate([0, 0, r/2]) cube([4*r, 4*r, r], center = true);
    }
}

// cuerpo con fondo plano y canto superior redondeado
module cuerpo() {
    minkowski() {
        linear_extrude(height = max(0.1, ESPESOR - RADIO_CANTO))
            perfil_2d(RADIO_CANTO);
        semiesfera(RADIO_CANTO);
    }
}

// Hueco central rebajado.
// El prisma termina RADIO_INT por debajo de la cara superior, asi que al
// hacer el minkowski la esfera muere tangente a esa cara: el filo de
// arriba queda redondeado de verdad (no vertical), y el encuentro con el
// piso lleva el mismo radio. El marco mide ANCHO_MARCO justo en la cara
// superior, que es donde se ve.
module hundido() {
    minkowski() {
        translate([0, 0, ESPESOR - PROF_HUNDIDO + RADIO_INT])
            linear_extrude(height = max(0.1, PROF_HUNDIDO - 2*RADIO_INT))
                perfil_2d(ANCHO_MARCO);
        sphere(r = RADIO_INT);
    }
}

module pieza() {
    difference() {
        cuerpo();
        hundido();
        translate([AGUJERO_X, AGUJERO_Y, -1])
            cylinder(h = ESPESOR + 2, d = AGUJERO_D);
    }
}

pieza();
