// Slanted stand for the Dell Optiplex 9020 open-frame tray  (v4, optimized for printing)
// Bambu Lab A1 (256 x 256 x 256 mm bed).
//
// A kit of 4 printed parts: a LEFT and a RIGHT side frame (mirror images, because
// the bar pockets are on the inner faces) and TWO identical base bars.
//  - Each side frame prints FLAT on its outer face, so every layer runs along the
//    frame and the loads follow the layer lines (strongest direction). No supports.
//  - The frames are open triangles (already rigid) with thin bands and rounded
//    inside corners, with extra material only where the tray bolts on (the sloped
//    top band) and where the bars plug in (the base band).
//  - Each bar has a tenon at both ends that slots into a pocket in the frame,
//    so it can't twist, and is held by one M4 x 20 screw per end.
//
// HOW TO USE: `part` (below) picks what is shown and exported with F6 then F7.
//   "all"      = the 4 pieces, separated and laid out side by side (default)
//   "left"     = the left side frame            "right" = the right side frame (mirror)
//   "bar"      = one base bar (print 2x)
//   "plate1"   = left frame + both bars on one A1 build plate;  "plate2" = right frame
//   "assembly" = the finished stand, put together (preview only)
// Axes (assembly): x = tray width, y = depth (front to back), z = up.

part = "all";         // "all" | "left" | "right" | "bar" | "plate1" | "plate2" | "assembly"

/* ---------- Tray (must match the tray file) ---------- */
board_w     = 200;
board_d     = 218;
margin      = 5;
tray_t      = 4;
mount_inset = 7;      // corner mounting hole distance from the tray edges

tray_w = board_w + 2*margin;     // 210
tray_d = board_d + 2*margin;     // 228

/* ---------- Stand shape ---------- */
tilt        = 55;     // degrees from horizontal (90 = fully upright)
h0          = 25;     // height of the tray's low edge above the table
foot_front  = 55;     // base reaches this far in front of the tray's low edge
foot_back   = 25;     // ...and this far behind the tray's high edge
rail_w      = 12;     // side frame thickness (outer face is x = 0)

/* ---------- Frame structure (the filament savers) ---------- */
band        = 7;      // general frame band width
band_top    = 12;     // band under the tray (holds the screws)
band_base   = 11;     // band along the table (holds the bar pockets)
corner_r    = 5;      // rounded inside corners (stronger, no stress cracks)

/* ---------- Screws and bars ---------- */
rail_hole_d = 3.3;    // M4 self-tapping into plastic (5.6 for heat-set inserts)
hole_depth  = 9;      // tray screws: M4 x 12 (4 mm tray + 8 mm into the frame)
bar_d       = 14;     // bar depth (front to back)
bar_h       = 7;      // bar height
bar_inset   = 4;      // wall between the bar pocket and the frame end
tenon_l     = 4;      // tenon length (pocket depth)
tol         = 0.3;    // fit clearance around the tenon
bar_screw   = 4.4;    // M4 clearance through the frame
bar_pilot   = 3.3;    // M4 self-tap pilot in the bar end
bar_pilot_l = 14;     // pilot depth

show_tray   = true;   // ghost of the tray in the preview only

/* ---------- Bambu Lab A1 print bed ---------- */
bed_x = 256; bed_y = 256; bed_z = 256; bed_clearance = 10;

/* ---------- Center of gravity (balance the loaded tray to tune) ---------- */
cog_s  = tray_d/2;    // distance up the slope from the low edge
cog_up = 35;          // height of the mass above the tray surface (cooler, GPU)

/* ---------- Derived geometry ---------- */
function top_y(s) = s*cos(tilt);
function top_z(s) = h0 + s*sin(tilt);

base_y0 = -foot_front;
base_y1 = top_y(tray_d) + foot_back;
tip_h   = band_base;                 // height of the frame's front tip

bar_y_front = base_y0 + bar_inset;
bar_y_back  = base_y1 - bar_inset - bar_d;
bar_x0      = rail_w - (tenon_l - 0.2);
bar_len     = tray_w - 2*rail_w + 2*(tenon_l - 0.2);

hole_s = [mount_inset, tray_d - mount_inset];   // along the slope

/* ---------- Console checks ---------- */
size_y = base_y1 - base_y0;
size_z = top_z(tray_d);
cog_y = top_y(cog_s) - cog_up*sin(tilt);
cog_z = top_z(cog_s) + cog_up*cos(tilt);
tip_front = atan((cog_y - base_y0)/cog_z);
tip_back  = atan((base_y1 - cog_y)/cog_z);
tip_side  = atan((tray_w/2)/cog_z);
echo(str("Mount hole spacing: ", tray_w - 2*mount_inset, " x ", tray_d - 2*mount_inset, " mm"));
echo(str("Stand footprint: ", tray_w, " x ", size_y, " x ", size_z, " mm"));
echo(str("Each frame prints flat: ", size_y, " x ", size_z, " x ", rail_w, " mm"));
echo(str("Tip-over angle  front: ", tip_front, "  back: ", tip_back, "  side: ", tip_side, " deg"));
if (size_y > bed_y - bed_clearance || size_z > bed_x - bed_clearance)
    echo("WARNING: a frame does not fit the A1 print bed with clearance.");
if (min(tip_front, tip_back, tip_side) < 30)
    echo("WARNING: tip-over angle under 30 deg. Lengthen foot_front or foot_back.");

/* ---------- Side frame profile (2D: x = depth y, y = height z) ---------- */
module outer_profile() {
    polygon([[base_y0, 0], [base_y1, 0],
             [top_y(tray_d), top_z(tray_d)], [top_y(0), top_z(0)],
             [base_y0, tip_h]]);
}

// thicker band under the tray, where the screws go
module top_strip() {
    translate([top_y(0), top_z(0)]) rotate(tilt)
        translate([0, -band_top]) square([tray_d, band_top]);
}

// thicker band along the table, where the bars plug in
module base_strip() {
    translate([base_y0, 0]) square([base_y1 - base_y0, band_base]);
}

// the empty space inside the frame, with rounded corners
module hollow() {
    offset(r = corner_r) offset(delta = -corner_r)
        difference() {
            offset(delta = -band) outer_profile();
            top_strip();
            base_strip();
        }
}

module profile() {
    difference() { outer_profile(); hollow(); }
}

/* ---------- 3D parts ---------- */
// Side frame in "raw" coordinates: X = depth y, Y = height z, Z = width x.
// Z = 0 is the outer face (down on the print bed), Z = rail_w is the inner face.
module rail_raw() {
    difference() {
        linear_extrude(height = rail_w) profile();

        // tray screw holes, drilled perpendicular to the slope
        for (s = hole_s)
            translate([top_y(s), top_z(s), mount_inset])
                rotate([0, 0, tilt]) rotate([90, 0, 0])
                    translate([0, 0, -1])
                        cylinder(d = rail_hole_d, h = hole_depth + 1, $fn = 40);

        // bar pockets (open on the inner face) and the bar screws
        for (by = [bar_y_front, bar_y_back]) {
            translate([by - tol, -1, rail_w - tenon_l])
                cube([bar_d + 2*tol, bar_h + tol + 1, tenon_l + 1]);
            translate([by + bar_d/2, bar_h/2, -1])
                cylinder(d = bar_screw, h = rail_w + 2, $fn = 30);
        }
    }
}

// Base bar, lying flat as printed: X = length, Y = depth, Z = height.
module bar_raw() {
    difference() {
        cube([bar_len, bar_d, bar_h]);
        for (x = [-1, bar_len - bar_pilot_l])
            translate([x, bar_d/2, bar_h/2]) rotate([0, 90, 0])
                cylinder(d = bar_pilot, h = bar_pilot_l + 1, $fn = 24);
    }
}

module assembly() {
    // left frame, and the right frame as its mirror image
    rotate([90, 0, 90]) rail_raw();
    translate([tray_w, 0, 0]) mirror([1, 0, 0]) rotate([90, 0, 90]) rail_raw();
    // base bars
    for (y = [bar_y_front, bar_y_back]) translate([bar_x0, y, 0]) bar_raw();
    // ghost of the tray in place (preview only, never exported)
    if (show_tray)
        %translate([0, top_y(0), top_z(0)]) rotate([tilt, 0, 0])
            cube([tray_w, tray_d, tray_t]);
}

/* ---------- Build plate layouts (Bambu Lab A1) ---------- */
plate_gap = 3;                        // space between parts on the plate

// LEFT frame, outer face down, in the plate's corner
module frame_left() { translate([-base_y0, 0, 0]) rail_raw(); }

// RIGHT frame: the mirror image of the left one, also outer face down
module frame_right() { translate([size_y, 0, 0]) mirror([1, 0, 0]) frame_left(); }

// the base bars, lying flat in a row above the frame
module plate_bars() {
    for (i = [0, 1])
        translate([0, size_z + plate_gap + i*(bar_d + plate_gap), 0]) bar_raw();
}

// all 4 pieces separated and laid out in a grid, just for viewing
module all_pieces() {
    gap = 10;
    frame_left();
    translate([size_y + gap, 0, 0]) frame_right();
    for (i = [0, 1]) translate([i*(size_y + gap), -(bar_d + gap), 0]) bar_raw();
}

if (part == "all") all_pieces();
else if (part == "left") frame_left();
else if (part == "right") frame_right();
else if (part == "bar") bar_raw();
else if (part == "plate1") { frame_left(); plate_bars(); }
else if (part == "plate2") frame_right();
else assembly();

// plate 1 needs this much of the bed (must stay under the A1's 256 mm)
echo(str("Plate 1 size: ", size_y, " x ", size_z + plate_gap + 2*bar_d + plate_gap, " mm"));