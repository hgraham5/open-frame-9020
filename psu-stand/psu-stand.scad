// PSU support stand -- capital "A" shape with a middle crossbar.
// Open-frame-9020 project. Printed flat (2D profile extruded), same style
// as the other parts in this repo (frame-base.scad / motherboard-tray.scad).
//
// The two foot holes match the motherboard tray's motherboard screw holes
// (hole_d = 3.2 mm -> M3), so the stand can be bolted down the same way the
// board is. A single hole of the same size sits at the peak, 49.2125 mm
// above the base, for bolting on whatever straps/holds the PSU.

/* ---------- Holes (match motherboard-tray.scad hole_d) ---------- */
hole_d       = 3.2;        // M3 clearance -- same as motherboard-tray.scad "motherboard screw holes"
pad_d        = 10;         // round pad around each hole

/* ---------- Shape ---------- */
stand_t      = 2;          // extrusion thickness (printed flat)
leg_w        = 8;         // stroke width of each leg of the "A"
base_spread  = 75;         // distance between the two feet centers
foot_w       = 11;         // width of the flat foot pad at the base of each leg
foot_h       = 10;         // height of the flat foot pad
foot_hole_h  = 8;          // foot screw hole height above the stand's bottom edge
crossbar_h   = 28;         // height of the crossbar (center support) above the bottom edge
peak_hole_h  = 49.2125;    // height of the peak hole above the base of the "A"

/* ---------- Derived ---------- */
leg_x  = base_spread/2;
apex_y = peak_hole_h;       // the two legs converge at the peak hole's pad

// x position of a leg's centerline at height y, interpolated from the top
// of the foot (leg_x, foot_h) straight up to the apex (0, apex_y)
function leg_x_at(y) = leg_x * (1 - (y - foot_h) / (apex_y - foot_h));

module foot(x) {
    translate([x - foot_w/2, 0]) square([foot_w, foot_h]);
}

module leg(x) {
    hull() {
        translate([x, foot_h]) circle(d = leg_w, $fn = 30);
        translate([0, apex_y]) circle(d = leg_w, $fn = 30);
    }
}

module crossbar() {
    hull() {
        translate([ leg_x_at(crossbar_h), crossbar_h]) circle(d = leg_w, $fn = 30);
        translate([-leg_x_at(crossbar_h), crossbar_h]) circle(d = leg_w, $fn = 30);
    }
}

module stand_2d() {
    foot(leg_x);
    foot(-leg_x);
    leg(leg_x);
    leg(-leg_x);
    crossbar();
    translate([0, apex_y]) circle(d = pad_d, $fn = 40);
}

difference() {
    linear_extrude(height = stand_t) stand_2d();

    // foot mounting holes (same size as the tray's motherboard screw holes)
    translate([ leg_x, foot_hole_h, -1]) cylinder(d = hole_d, h = stand_t + 2, $fn = 30);
    translate([-leg_x, foot_hole_h, -1]) cylinder(d = hole_d, h = stand_t + 2, $fn = 30);

    // peak hole, 49.2125 mm above the base, same size
    translate([0, apex_y, -1]) cylinder(d = hole_d, h = stand_t + 2, $fn = 30);
}

echo(str("PSU stand footprint: ", base_spread + foot_w, " x ", apex_y + leg_w/2, " mm"));
echo(str("Peak hole height above base: ", peak_hole_h, " mm"));
