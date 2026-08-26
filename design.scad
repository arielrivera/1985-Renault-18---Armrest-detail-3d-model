$fn = 80; 

// Part Dimensions (in millimeters)
//max_length = 45;
max_length = 52;
max_width = 29;
rim_height = 4;
center_height = 2;
rim_wall_thickness = 2;
corner_radius = 6; 

// Center hole diameter (1 cm = 10 mm)
screw_diameter = 10; 

module base_silhouette() {
    hull() {
        // Bottom Left
        translate([corner_radius + 5.5, corner_radius, 0]) circle(r = corner_radius);
        // Bottom Right
        translate([max_length - corner_radius, corner_radius, 0]) circle(r = corner_radius);
        // Top Left
        translate([corner_radius, max_width - corner_radius, 0]) circle(r = corner_radius);
        // Top Right
        translate([max_length - corner_radius - 5.5, max_width - corner_radius, 0]) circle(r = corner_radius);
    }
} 

difference() {
    union() {
        // 1. Flat center area (2mm thickness)
        linear_extrude(height = center_height) {
            base_silhouette();
        } 

        // 2. Raised outer rim (4mm total height)
        linear_extrude(height = rim_height) {
            difference() {
                base_silhouette();
                offset(r = -rim_wall_thickness) {
                    base_silhouette();
                }
            }
        }
    }

    // 3. Center screw hole perforation (10mm diameter)
    translate([max_length / 2, max_width / 2, -1]) {
        cylinder(h = rim_height + 2, d = screw_diameter);
    }
}