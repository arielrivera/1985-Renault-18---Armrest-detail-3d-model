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
RADIO_INT_SUP = 1.0; // redondeo del filo de ARRIBA del hundido (el que se ve)
RADIO_INT_INF = 0.4; // redondeo abajo, donde la pared se junta con el piso
ANCHO_MARCO= 3.0;   // ancho del marco: del filo exterior al inicio del hundido
PROF_HUNDIDO=1.6;   // cuanto se hunde la zona central respecto del marco
                    // (tiene que ser mayor que RADIO_INT_SUP + RADIO_INT_INF)

/* [Calidad] */
$fn = 96;

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

// ---- Hueco central rebajado --------------------------------------
// Perfil, caminando desde el centro hacia afuera y subiendo:
//
//                                    ____________  cara superior
//   piso del hundido ______        /   <- RADIO_INT_SUP: el filo de
//                          \      /      arriba sale en curva hacia
//        RADIO_INT_INF ->   \____/       la cara superior (convexo)
//                            pared
//
// La boca del hundido en la cara superior queda a ANCHO_MARCO del filo
// exterior; la pared vertical queda RADIO_INT_SUP mas adentro.
Z_PISO   = ESPESOR - PROF_HUNDIDO;
D_BOCA   = ANCHO_MARCO;                        // en la cara superior
D_PARED  = ANCHO_MARCO + RADIO_INT_SUP;        // pared vertical
D_PISO   = D_PARED + RADIO_INT_INF;            // borde del piso
PASOS    = 28;                                 // finura de los redondeos

// rebanada horizontal del hueco, metida d mm desde el filo exterior
module rebanada(z, d) {
    translate([0, 0, z]) linear_extrude(height = 0.01) perfil_2d(d);
}

// tramo curvo entre dos alturas (el contorno es convexo, asi que el
// hull entre dos rebanadas da la superficie reglada exacta)
module tramo(z0, d0, z1, d1) {
    hull() { rebanada(z0, d0); rebanada(z1, d1); }
}

module hundido() {
    union() {
        // 1) redondeo de arriba: de la pared (z = ESPESOR - RADIO_INT_SUP)
        //    hasta morir tangente a la cara superior
        for (i = [0 : PASOS-1]) {
            t0 = RADIO_INT_SUP * i / PASOS;
            t1 = RADIO_INT_SUP * (i+1) / PASOS;
            tramo(ESPESOR - RADIO_INT_SUP + t0,
                  D_PARED - RADIO_INT_SUP + sqrt(max(0, pow(RADIO_INT_SUP,2) - pow(t0,2))),
                  ESPESOR - RADIO_INT_SUP + t1,
                  D_PARED - RADIO_INT_SUP + sqrt(max(0, pow(RADIO_INT_SUP,2) - pow(t1,2))));
        }
        // 2) pared vertical
        tramo(Z_PISO + RADIO_INT_INF, D_PARED,
              ESPESOR - RADIO_INT_SUP + 0.01, D_PARED);
        // 3) acuerdo con el piso
        for (i = [0 : PASOS-1]) {
            s0 = RADIO_INT_INF * i / PASOS;
            s1 = RADIO_INT_INF * (i+1) / PASOS;
            tramo(Z_PISO + s0,
                  D_PISO - sqrt(max(0, pow(RADIO_INT_INF,2) - pow(RADIO_INT_INF-s0,2))),
                  Z_PISO + s1,
                  D_PISO - sqrt(max(0, pow(RADIO_INT_INF,2) - pow(RADIO_INT_INF-s1,2))));
        }
        // 4) todo lo que sobra por encima de la cara superior
        tramo(ESPESOR - 0.02, D_BOCA, ESPESOR + 2, D_BOCA);
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
