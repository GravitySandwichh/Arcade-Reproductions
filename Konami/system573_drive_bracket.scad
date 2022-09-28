/*
 * Konami System 573 drive bracket
 * (C) 2022 spicyjpeg
 *
 * A fairly minimal CD drive bracket replacement for 573s that don't have one,
 * printable as either 2 pieces (left and right sides) or 4 pieces (left/right,
 * front/back); splitting it into 4 pieces is recommended as it requires less
 * filament. Unlike the real thing this one has no shock damping to keep the
 * design simple. Compatible with both black and gray case variants of the 573,
 * however only full-sized 5.25 inch drives are supported (the measurements are
 * straight from the SFF-8501 specification).
 *
 * NOTE: you might have to tweak some variables, particularly Drive_Inset_Front
 * and Case_Hole_Diameter, depending on the drive and case screws you have.
 */

/* [Hidden] */

$fn = 100;

/* [Main] */

Mode = 0; // [ 0:Full bracket, 1:Front piece, 2:Back piece ]
Bracket_Side = 0; // [ 0:Left side, 1:Right side ]
Bracket_Thickness = 3.2;
// Distance from drive to 573 case
Drive_Inset_Top = 5.5;
// Distance from drive front panel to 573 front panel
Drive_Inset_Front = 8;

/* [Holes] */

// Minimum radius around the center of each hole
Hole_Margin = 5;
Case_Hole_Diameter = 2.6;
Case_Hole_Depth = 10;
Drive_Hole_Diameter = 3.2;
// Clearance around each drive hole
Drive_Hole_Countersink_Diameter = 8.5;
Drive_Hole_Bracket_Thickness = 1.6;

/* [Case] */

// Horizontal distance between each group of 2 holes
Case_Hole_Distance_X = 163.75;
// Vertical distance between each group of 2 holes
Case_Hole_Distance_Y = 70;
// Vertical distance between each hole of a group
Case_Hole_Spacing = 30.75;
// Vertical distance from holes to front panel
Case_Hole_Offset = 35;

/* [Drive] */

// Total width of drive (defined by spec)
Drive_Width = 146.05;
// Total height of drive (defined by spec)
Drive_Height = 42;
// Distance from side holes to bottom border (defined by spec)
Drive_Side_Hole_Offset = 9.91;
// Horizontal distance between bottom holes (defined by spec)
Drive_Side_Hole_Distance_X = 11.93;
// Distance from bottom holes to side border (defined by spec)
Drive_Bottom_Hole_Offset = 3.175;
// Horizontal distance between bottom holes (defined by spec)
Drive_Bottom_Hole_Distance_X = 139.7;
// Vertical distance from side/bottom holes to front panel (may vary)
Drive_Hole_Offset = 53;
// Vertical distance between side/bottom holes (defined by spec)
Drive_Hole_Distance_Y = 79.24;

Case_Hole_Position_X = (Case_Hole_Distance_X - Drive_Width) / 2;
Drive_Hole_Position_Y = -Case_Hole_Offset + Hole_Margin + Drive_Inset_Front + Drive_Hole_Offset;
Bracket_Width = Hole_Margin + Case_Hole_Position_X;
Bracket_Length = (Hole_Margin + Case_Hole_Spacing) * 2 + Case_Hole_Distance_Y;
Bracket_Height = Drive_Inset_Top + Drive_Height + Bracket_Thickness;
Inner_Depth = Hole_Margin + Drive_Bottom_Hole_Offset;
Bracket_Countersink_Height = Drive_Inset_Top + Drive_Height + Drive_Hole_Bracket_Thickness;

module Bracket_Outline() {
	union() {
		// Side
		hull() {
			square([ Bracket_Width, Drive_Inset_Top ]);
			square([ Bracket_Thickness, Bracket_Height ]);
		}
		// Top/bottom bracket
		translate([ -Inner_Depth, 0 ])
			square([ Inner_Depth, Drive_Inset_Top ]);
		translate([ -Inner_Depth, Drive_Inset_Top + Drive_Height ])
			square([ Inner_Depth, Bracket_Thickness ]);
	}
}

module Case_Hole() {
	cylinder(h = Case_Hole_Depth, d = Case_Hole_Diameter);
}

module Drive_Bottom_Hole() {
	union() {
		translate([ 0, 0, Drive_Inset_Top + Drive_Height ])
			cylinder(h = Bracket_Thickness, d = Drive_Hole_Diameter);
		translate([ 0, 0, Bracket_Countersink_Height ])
			cylinder(h = Bracket_Thickness - Drive_Hole_Bracket_Thickness, d = Drive_Hole_Countersink_Diameter);
	}
}

module Drive_Side_Hole() {
	rotate([ 0, -90, 0 ]) union() {
		cylinder(h = Drive_Hole_Bracket_Thickness, d = Drive_Hole_Diameter);
		translate([ 0, 0, Drive_Hole_Bracket_Thickness ])
			cylinder(h = Bracket_Width - Drive_Hole_Bracket_Thickness, d = Drive_Hole_Countersink_Diameter);
	}
}

module Case_Hole_Set() {
	union() {
		translate([ -Case_Hole_Position_X, 0, 0 ])
			Case_Hole();
		translate([ -Case_Hole_Position_X, Case_Hole_Spacing, 0 ])
			Case_Hole();
	}
}

module Drive_Hole_Set() {
	Hole_Z = Drive_Inset_Top + Drive_Height - Drive_Side_Hole_Offset;

	union() {
		// Bottom hole
		translate([ Drive_Bottom_Hole_Offset, 0, 0 ])
			Drive_Bottom_Hole();
		// Side holes
		translate([ 0, 0, Hole_Z ])
			Drive_Side_Hole();
		translate([ 0, 0, Hole_Z - Drive_Side_Hole_Distance_X ])
			Drive_Side_Hole();
	}
}

module Full_Bracket() {
	difference() {
		rotate([ 90, 0, 180 ]) linear_extrude(Bracket_Length)
			Bracket_Outline();
		// Case holes
		translate([ 0, Hole_Margin, 0 ])
			Case_Hole_Set();
		translate([ 0, Bracket_Length - Case_Hole_Spacing - Hole_Margin, 0 ])
			Case_Hole_Set();
		// Drive holes
		translate([ 0, Drive_Hole_Position_Y, 0 ])
			Drive_Hole_Set();
		translate([ 0, Drive_Hole_Position_Y + Drive_Hole_Distance_Y, 0 ])
			Drive_Hole_Set();
	}
}

module Main() {
	Shift = (Mode == 2) ? (Case_Hole_Spacing + Case_Hole_Distance_Y) : 0;

	if (Mode == 0)
		Full_Bracket();
	else intersection() {
		translate([ 0, -Shift, 0 ])
			Full_Bracket();
		translate([ -Bracket_Width, 0, 0 ])
			cube([ Inner_Depth + Bracket_Width, Hole_Margin * 2 + Case_Hole_Spacing, Bracket_Height ]);
	}
}

mirror([ 1 - Bracket_Side, 0, 0 ])
	Main();
