// Minimal slanted stand for the Dell Optiplex 9020 open-frame tray  (v3)
// Sized for a Bambu Lab A1 (256 x 256 x 256 mm bed): prints as ONE piece,
// standing upright exactly as modeled, with no supports needed.
//
// Two slim side frames bolt to the tray's four corner mounting holes and are
// tied together by two flat base bars. The tray leans back by `tilt` degrees.
// Axes: x = tray width, y = depth (front to back), z = up.

/* ---------- Tray (must match the tray file) ---------- */
board_w     = 200;
board_d     = 218;
margin      = 5;
tray_t      = 4;
mount_inset = 7;      // corner mounting hole distance from the tray edges

tray_w = board_w + 2*margin;     // 210
tray_d = board_d + 2*margin;     // 228

/* ---------- Stand settings ---------- */
tilt        = 55;     // degrees from horizontal (90 = fully upright)
h0          = 25;     // height of the tray's low edge above the table
rail_w      = 14;     // side frame thickness along x (centered on the mount holes)
frame_t     = 12;     // frame band width (must exceed hole_depth)
foot_front  = 55;     // base reaches this far in front of the tray's low edge
foot_back   = 25;     // ...and this far behind the tray's high edge
bar_d       = 14;     // base bar depth
rail_hole_d = 3.3;    // M4 self-tapping into plastic (5.6 for heat-set inserts)
hole_depth  = 10;     // use M4 x 12 screws
show_tray   = true;   // ghost of the tray in the preview only

/* ---------- Bambu Lab A1 print bed ---------- */
bed_x = 256;
bed_y = 256;
bed_z = 256;
bed_clearance = 10;   // keep this much free around the part (brim, purge line)

/* ---------- Center of gravity (balance the loaded tray to tune) ---------- */
cog_s  = tray_d/2;    // distance up the slope from the low edge
cog_up = 35;          // height of the mass above the tray surface (cooler, GPU)

/* ---------- Derived geometry ---------- */
function top_y(s) = s*cos(tilt);
function top_z(s) = h0 + s*sin(tilt);

base_y0 = -foot_front;
base_y1 = top_y(tray_d) + foot_back;

hole_s = [mount_inset, tray_d - mount_inset];   // along the slope
hole_x = [mount_inset, tray_w - mount_inset];   // across the width

/* ---------- Console checks: print bed fit and stability ---------- */
size_x = tray_w;
size_y = base_y1 - base_y0;
size_z = top_z(tray_d);

cog_y = top_y(cog_s) - cog_up*sin(tilt);
cog_z = top_z(cog_s) + cog_up*cos(tilt);
tip_front = atan((cog_y - base_y0)/cog_z);
tip_back  = atan((base_y1 - cog_y)/cog_z);
tip_side  = atan((tray_w/2)/cog_z);

echo(str("Mount hole spacing: ", tray_w - 2*mount_inset, " x ", tray_d - 2*mount_inset, " mm"));
echo(str("Part size: ", size_x, " x ", size_y, " x ", size_z, " mm"));
echo(str("Tip-over angle  front: ", tip_front, "  back: ", tip_back, "  side: ", tip_side, " deg"));
if (size_x > bed_x - bed_clearance || size_y > bed_y - bed_clearance || size_z > bed_z)
    echo("WARNING: part does not fit the A1 print bed with clearance.");
if (min(tip_front, tip_back, tip_side) < 30)
    echo("WARNING: tip-over angle under 30 deg. Lengthen foot_front or foot_back.");

/* ---------- Side frame profile (y, z) ---------- */
module outer_profile() {
    polygon([[base_y0, 0], [base_y1, 0],
             [top_y(tray_d), top_z(tray_d)], [top_y(0), top_z(0)]]);
}

module profile() {
    difference() {
        outer_profile();
        offset(delta = -frame_t) outer_profile();
    }
}

/* ---------- 3D parts ---------- */
// the 2D (y,z) profile extruded along x
module side_frame() {
    rotate([90, 0, 90]) linear_extrude(height = rail_w) profile();
}

// flat bars at the front and back of the base, joining the two side frames
module base_bars() {
    for (y = [base_y0, base_y1 - bar_d])
        translate([0, y, 0]) cube([tray_w, bar_d, frame_t]);
}

// screw holes drilled perpendicular to the slope, under each tray mount hole
module screw_holes() {
    for (x = hole_x) for (s = hole_s)
        translate([x, top_y(s), top_z(s)])
            rotate([tilt, 0, 0])
                translate([0, 0, -hole_depth])
                    cylinder(d = rail_hole_d, h = hole_depth + 1, $fn = 40);
}

module stand() {
    difference() {
        union() {
            for (x = [0, tray_w - rail_w]) translate([x, 0, 0]) side_frame();
            base_bars();
        }
        screw_holes();
    }
}

stand();

// ghost of the tray in place (preview only, never exported)
if (show_tray)
    %translate([0, top_y(0), top_z(0)]) rotate([tilt, 0, 0])
        cube([tray_w, tray_d, tray_t]);