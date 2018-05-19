set project "esp-walkie-talkie-hw"
set output "ewt"
set gcode_preamble "G0 F200\nG1 F50\nM3 S12000"

# Run around the edge a few times to help verify engraving depth.
open_gerber "$project-Edge.Cuts.gbr" -outname Edges
isolate Edges -dia 0.4 -passes 2 -overlap 0.0 -combine 1 -outname PreEdges.iso
exteriors PreEdges.iso -outname PreEdges.ext
delete PreEdges.iso
cncjob PreEdges.ext -z_cut -0.1 -z_move 1.0 -feedrate 50 -tooldia 0.2 -outname PreEdges.iso.cnc
write_gcode PreEdges.iso.cnc "$output-PreEdges_iso01.ngc" -preamble "$gcode_preamble"

open_gerber "$project-B.Cu.gbr" -outname BCu
isolate BCu -dia 0.29 -passes 3 -overlap 0.4 -combine 1 -outname BCu.iso_01
isolate BCu -dia 1.0 -passes 2 -overlap 0.5 -combine 1 -outname BCu.iso_08
cncjob BCu.iso_01 -z_cut -0.1 -z_move 1.0 -feedrate 50 -tooldia 0.2 -outname BCu.iso_01.cnc
cncjob BCu.iso_08 -z_cut -0.1 -z_move 1.0 -feedrate 100 -tooldia 0.8 -outname BCu.iso_08.cnc
write_gcode BCu.iso_01.cnc "$output-BCu_iso01.ngc" -preamble "$gcode_preamble"
write_gcode BCu.iso_08.cnc "$output-BCu_iso08.ngc" -preamble "$gcode_preamble\nG1 F100"

open_excellon "$project.drl" -outname Holes
drillcncjob Holes -drillz -1.8 -travelz 1.0 -feedrate 50 -tools 1 -outname Holes_03.cnc
millholes Holes -tooldia 0.7 -tools 2,3,4,5 -outname Holes_08
cncjob Holes_08 -z_cut -1.8 -z_move 1.0 -feedrate 50 -tooldia 0.8 -outname Holes_08.cnc
write_gcode Holes_03.cnc "$output-Holes_03.ngc" -preamble "$gcode_preamble"
write_gcode Holes_08.cnc "$output-Holes_08.ngc" -preamble "$gcode_preamble"

isolate Edges -dia 0.8 -passes 1 -outname Edges.iso
exteriors Edges.iso -outname Edges.ext
cncjob Edges.ext -z_cut -1.8 -z_move 1.0 -feedrate 50 -tooldia 0.8 -multidepth 1 -depthperpass 1.0 -outname Edges.cnc
write_gcode Edges.cnc "$output-Edges_08.ngc" -preamble "$gcode_preamble"

exec cat "$output-BCu_iso08.ngc" "$output-Holes_08.ngc" "$output-Edges_08.ngc" > "$output-All_08.ngc"

