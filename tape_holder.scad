tape_inner_diameter = 77.5;
tape_max_outer_diameter = 108;
tape_width = 30.5;

tape_part_thickness = 2;
tape_part_width = tape_width + 0.5;
tab_height = 3;

tape_part_outer_diameter = (tape_inner_diameter * 0.95);
tape_part_inner_diameter = tape_part_outer_diameter - (tape_part_thickness * 2);
tape_part_tab_diameter = tape_inner_diameter + tab_height;

echo("tape_inner_diameter: ", tape_inner_diameter);
echo("tape_max_outer_diameter: ", tape_max_outer_diameter);
echo("tape_width: ", tape_width);

echo("tape_part_thickness: ", tape_part_thickness);
echo("tape_part_width: ", tape_part_width);
echo("tab_height: ", tab_height);

echo("tape_part_outer_diameter: ", tape_part_outer_diameter);
echo("tape_part_inner_diameter: ", tape_part_inner_diameter);
echo("tape_part_tab_diameter: ", tape_part_tab_diameter);

module tape_part(generate_tabs = true) {
    module add_tab() {
        translate([tape_part_width, 0, 0]) {
            rotate([0, 90, 0]) {
                    linear_extrude(height = tape_part_thickness) {
                        intersection() {
                            difference(){
                                circle(d = tape_part_tab_diameter, $fn=360);
                                circle(d = tape_part_inner_diameter, $fn=360);     
                            }

                            polygon(points = [
                                [0, 0],
                                [-tape_part_tab_diameter, tape_part_tab_diameter],
                                [-tape_part_tab_diameter, -tape_part_tab_diameter]
                                ]);
                            }
                    }
            }
        }
    }

    rotate([0, 90, 0]){
        linear_extrude(height = tape_part_width){
            difference(){
                circle(d = tape_part_outer_diameter, $fn=360);
                circle(d = tape_part_inner_diameter, $fn=360);
            }
        }
    }
    
    if (generate_tabs) {
        add_tab();
    }
}

module pegboard_mount(generate_pegs = true) {
    backplate_height = 50;
    backplate_width = 35.4;
    backplate_thickness = 3;
    max_outer_radius = (tape_max_outer_diameter / 2);
    pegs_spacing = 25.4;

    module backplate()
    {
        rotate([-90, 0, 0]) {
            linear_extrude(height = backplate_thickness){
                square([backplate_width, backplate_height]);
            }
        }
    }

    module pegboard_pegs(){
        upper_peg_edge = 4.5;
        upper_peg_inner_diameter = 14;
        rotate([0, 90, 0]) {
            translate([(-11.5 + (upper_peg_edge / 2)) - 25, 0, -(upper_peg_edge / 2)]){
                linear_extrude(height = upper_peg_edge){
                    intersection() {
                        difference(){
                            circle(d = upper_peg_inner_diameter + (upper_peg_edge * 2), $fn=50);
                            circle(d = upper_peg_inner_diameter, $fn=50);
                        }
            
                        polygon(points = [
                            [0, 0],
                            [20, 0],
                            [0, 20]
                            ]);
                    }
                }
            }
            rotate([-90, 0, 0]) {
                cylinder(d = 6, h=10, $fn=30);
            }
        }
    }


    if (generate_pegs) {
        translate([0, max_outer_radius + 2, max_outer_radius - 32]){
            for (i = [0:1]) {
                translate([5 + (i * pegs_spacing), backplate_thickness, 0]) {
                    pegboard_pegs();
                }
            }
        }
    }

    translate([0, max_outer_radius + 2, max_outer_radius]){
        backplate();
    }
}

module bridge_part() {
    bridge_thickness = 3;
    module bridge_part_filled(){
        translate([-bridge_thickness, 0, 0]){
            rotate([0, 90, 0]){
                linear_extrude(height = bridge_thickness) {

                    difference(){
                        hull() {
                            projection() {
                                rotate([0, -90, 0]) {
                                    tape_part(false);
                                    pegboard_mount(false);
                                }
                            }
                        }
                        circle(d = tape_part_inner_diameter, $fn=360);
                    }
                }
            }
        }
    }

    module add_tab() {
        translate([-bridge_thickness, 0, 0]) {
            rotate([0, 90, 0]) {
                linear_extrude(height = bridge_thickness) {
                    difference(){
                        circle(d = tape_part_tab_diameter, $fn=360);
                        circle(d = tape_part_inner_diameter, $fn=360);     
                    }
                }
            }
        }
    }

    bridge_part_filled();
    add_tab();
}

tape_part();
pegboard_mount();
bridge_part();
