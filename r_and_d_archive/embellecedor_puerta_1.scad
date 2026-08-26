// ============================================================
//  Embellecedor / tapa de puerta (descansabrazos)
//  Pieza decorativa - fondo plano, se pega con cinta doble faz
//  Modelo parametrico: cambia los valores de abajo y re-exporta
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
RADIO_CANTO= 1.8;   // redondeo del canto exterior (el "bordon" abombado)
ALTURA_DOMO= 0.5;   // curvatura general tipo domo de la cara superior
ANCHO_MARCO= 3.2;   // ancho del marco elevado del borde
PROF_HUNDIDO=1.2;   // cuanto se hunde la zona central respecto del marco

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

module perfil_2d(largo, ancho, r) {
    offset(r = r) offset(r = -r)
        scale([largo, ancho]) polygon(CONTORNO);
}

module semiesfera(r) {
    intersection() {
        sphere(r = r);
        translate([0, 0, r/2]) cube([4*r, 4*r, r], center = true);
    }
}

// cuerpo con fondo plano y canto superior redondeado
module cuerpo() {
    resize([LARGO, ANCHO, ESPESOR], auto = false)
    minkowski() {
        linear_extrude(height = max(0.1, ESPESOR - RADIO_CANTO))
            perfil_2d(LARGO - 2*RADIO_CANTO, ANCHO - 2*RADIO_CANTO,
                      max(0.5, RADIO_ESQ - RADIO_CANTO));
        semiesfera(RADIO_CANTO);
    }
}

// ---- domo: esfera muy grande que da la curvatura de la cara superior ----
RMAX  = sqrt(pow(LARGO/2, 2) + pow(ANCHO/2, 2));           // radio hasta la esquina
RDOMO = (pow(RMAX, 2) + pow(ALTURA_DOMO, 2)) / (2*ALTURA_DOMO);

// solido esferico cuya cumbre queda en z = z_cumbre
module domo(z_cumbre) {
    translate([0, 0, z_cumbre - RDOMO]) sphere(r = RDOMO, $fn = 220);
}

// ---- plato central concavo (la zona hundida dentro del marco) ----
RREF  = LARGO/2 - ANCHO_MARCO;                              // hasta donde se difumina
RPLATO= (pow(RREF, 2) + pow(PROF_HUNDIDO, 2)) / (2*PROF_HUNDIDO);

module hundido() {
    intersection() {
        translate([0, 0, -1])
            linear_extrude(height = ESPESOR + 20)
                perfil_2d(LARGO - 2*ANCHO_MARCO, ANCHO - 2*ANCHO_MARCO,
                          max(0.5, RADIO_ESQ - ANCHO_MARCO));
        translate([0, 0, ESPESOR - PROF_HUNDIDO + RPLATO])
            sphere(r = RPLATO, $fn = 220);
    }
}

module pieza() {
    difference() {
        intersection() {
            cuerpo();
            domo(ESPESOR);        // recorta la cara superior dandole el domo
        }
        hundido();
        translate([AGUJERO_X, AGUJERO_Y, -1])
            cylinder(h = ESPESOR + 2, d = AGUJERO_D);
    }
}

// el resize final garantiza que el bulto quede exactamente en 45 x 29 x 4 mm
resize([LARGO, ANCHO, ESPESOR], auto = false) pieza();
