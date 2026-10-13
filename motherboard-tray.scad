// Dell Optiplex 9020 open-frame tray
board_w = 200;   // board outline
board_d = 218;
margin  = 5;          // tray extends past the board on every side
frame_w = 8;          // perimeter frame width
rib_w   = 6;          // rib width
pad_d   = 10;         // pad under each standoff
tray_t  = 4;
standoff_h = 5;
standoff_d = 7;
hole_d  = 3.2;        // motherboard screw holes
hole_cooler = 2.8;    // CPU cooler holes (C, D, F, G), tune with a test coupon

// Corner mounting holes (for bolting the tray to stands)
mount_d      = 4.5;   // 4.5 = M4 clearance; use 3.4 for M3
mount_inset  = 7;     // hole center distance from each tray edge
mount_pad_d  = 14;    // round pad around each mounting hole

// A..J, measured from the board's origin corner
holes = [
    [4.7625,    9.525],     // 0 A
    [7.9375,   105.56875], // 1 B
    [57.15, 45.24375],  // 2 C (cooler)
    [133.35,  45.24375],  // 3 D (cooler)
    [170.65625, 9.525],   // 4 E
    [57.15, 121.44375], // 5 F (cooler)
    [133.35,  120.65],    // 6 G (cooler)
    [40.48125, 171.54],   // 7 H
    [40.48125, 213.51875],// 8 I
    [194.865625,   206.375]    // 9 J
];

// One screw-hole diameter per hole, same order as holes (A..J)
hole_ds = [hole_d, hole_d, hole_cooler, hole_cooler, hole_d,
           hole_cooler, hole_cooler, hole_d, hole_d, hole_d];

// Which holes get connected by ribs (indices into holes)
ribs = [[0,4],[0,1],[0,2],[2,3],[3,4],[2,5],[3,6],[5,6],
        [1,5],[5,7],[7,8],[6,9],[8,9],[4,9],[1,7],[6,7]];

// Extra supports: [hole index, frame edge it runs to]
// "L" = left, "R" = right, "B" = bottom, "T" = top
supports = [[1,"L"],[7,"L"],[2,"B"],[4,"B"],[3,"R"],[6,"R"]];

tray_w = board_w + 2*margin;
tray_d = board_d + 2*margin;

// Corner mount hole centers, in tray coordinates
mounts = [
    [mount_inset,           mount_inset],
    [tray_w - mount_inset,  mount_inset],
    [mount_inset,           tray_d - mount_inset],
    [tray_w - mount_inset,  tray_d - mount_inset]
];

module rib(a, b, w) {
    hull() {
        translate(a) circle(d=w, $fn=30);
        translate(b) circle(d=w, $fn=30);
    }
}

// Straight rib from a hole to the middle of the nearest frame edge
module edge_support(i, side) {
    p = [holes[i][0] + margin, holes[i][1] + margin];   // hole in tray coords
    target = side == "L" ? [frame_w/2,           p[1]] :
             side == "R" ? [tray_w - frame_w/2,  p[1]] :
             side == "B" ? [p[0],                frame_w/2] :
                           [p[0],                tray_d - frame_w/2];
    rib(p, target, rib_w);
}

module tray_2d() {
    // perimeter frame
    difference() {
        square([tray_w, tray_d]);
        translate([frame_w, frame_w])
            square([tray_w - 2*frame_w, tray_d - 2*frame_w]);
    }
    // corner pads for the mounting holes
    for (m = mounts) translate(m) circle(d=mount_pad_d, $fn=50);
    // extra supports from holes to the frame
    for (s = supports) edge_support(s[0], s[1]);
    // pads and ribs, shifted so the board origin sits at (margin, margin)
    translate([margin, margin]) {
        for (h = holes) translate(h) circle(d=pad_d, $fn=40);
        for (r = ribs) rib(holes[r[0]], holes[r[1]], rib_w);
    }
}

difference() {
    union() {
        linear_extrude(height=tray_t) tray_2d();
        translate([margin, margin, tray_t])
            for (h = holes)
                translate([h[0], h[1], 0])
                    cylinder(d=standoff_d, h=standoff_h, $fn=40);
    }
    // screw holes through standoffs and tray, each with its own diameter
    translate([margin, margin, -1])
        for (i = [0:len(holes)-1])
            translate([holes[i][0], holes[i][1], 0])
                cylinder(d=hole_ds[i], h=tray_t + standoff_h + 2, $fn=40);
    // corner mounting holes
    for (m = mounts)
        translate([m[0], m[1], -1])
            cylinder(d=mount_d, h=tray_t + 2, $fn=40);
}