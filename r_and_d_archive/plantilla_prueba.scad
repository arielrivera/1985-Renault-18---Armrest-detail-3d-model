// Plantilla de prueba: mismo contorno y agujero, solo 1 mm de espesor.
// Imprimela primero (2-3 minutos) para verificar el calce en la puerta
// antes de gastar tiempo/material en la pieza final.

LARGO = 45; ANCHO = 29; ESPESOR = 1; AGUJERO_D = 10; RADIO_ESQ = 7;
$fn = 64;

CONTORNO = [
    [-0.5000,  0.3759],
    [-0.3067, -0.5000],
    [ 0.5000, -0.3759],
    [ 0.3067,  0.5000]
];

difference() {
    resize([LARGO, ANCHO, ESPESOR], auto = false)
        linear_extrude(height = ESPESOR)
            offset(r = RADIO_ESQ) offset(r = -RADIO_ESQ)
                scale([LARGO, ANCHO]) polygon(CONTORNO);
    translate([0, 0, -1]) cylinder(h = ESPESOR + 2, d = AGUJERO_D);
}
