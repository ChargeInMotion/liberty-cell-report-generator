#!/usr/bin/env python3
"""Generates small SYNTHETIC Liberty corner libs (fast.lib + slow.lib) so the tool is
runnable without redistributing any licensed PDK. Same cells, corner-appropriate values."""
import sys
CELLS = [  # name, footprint, area, input pins, output, function
 ("INVX1","inv",1.064,["A"],"Y","!A"),("INVX2","inv",1.330,["A"],"Y","!A"),
 ("BUFX2","buf",1.596,["A"],"Y","A"),
 ("NAND2X1","nand2",1.330,["A","B"],"Y","!(A&B)"),("NOR2X1","nor2",1.330,["A","B"],"Y","!(A+B)"),
 ("AND2X1","and2",1.596,["A","B"],"Y","(A&B)"),("OR2X1","or2",1.596,["A","B"],"Y","(A+B)"),
 ("XOR2X1","xor2",2.128,["A","B"],"Y","(A^B)"),("XNOR2X1","xnor2",2.128,["A","B"],"ZN","!(A^B)"),
 ("MX2X1","mux2",2.660,["A","B","S0"],"Y","(A S0\\')+(B S0)"),
 ("ADDHX1","addh",3.192,["A","B"],"CO","(A&B)"),
 ("TIEHIX1","tieh",0.798,[],"Y","1"),
]
def lib(corner,V,T,dscale,lscale):
    o=[f'library({corner}) {{','  delay_model : table_lookup;','  time_unit : "1ns";',
       '  voltage_unit : "1V";','  current_unit : "1mA";','  leakage_power_unit : "1nW";',
       '  capacitive_load_unit (1,pf);',f'  nom_process : 1;',f'  nom_voltage : {V};',
       f'  nom_temperature : {T};',f'  operating_conditions({corner}) {{','    process : 1;',
       f'    voltage : {V};',f'    temperature : {T};','    tree_type : balanced_tree;','  }',
       f'  default_operating_conditions : {corner};','']
    for nm,fp,area,ins,out,fn in CELLS:
        o.append(f'cell ({nm}) {{')
        o.append(f'  area : {area};')
        o.append(f'  cell_leakage_power : {round(2.0*lscale*len(ins or [1]),3)};')
        o.append(f'  cell_footprint : {fp};')
        for p in ins:
            o += [f'  pin ({p}) {{','    direction : input;','    capacitance : 0.0021;','  }']
        d=round(0.018*dscale*(1+0.3*len(ins)),4); pw=round(0.9*lscale,4)
        o += [f'  pin ({out}) {{','    direction : output;',f'    function : "{fn}";',
              '    max_capacitance : 0.4;']
        for p in (ins or ["A"]):
            o += ['    timing () {',f'      related_pin : "{p}";','      timing_sense : negative_unate;',
                  f'      cell_rise (scalar) {{ values("{d}"); }}',
                  f'      cell_fall (scalar) {{ values("{round(d*0.95,4)}"); }}','    }',
                  '    internal_power () {',f'      related_pin : "{p}";',
                  f'      rise_power (scalar) {{ values("{pw}"); }}',
                  f'      fall_power (scalar) {{ values("{round(pw*0.9,4)}"); }}','    }']
        o += ['  }','}','']
    o.append('}')
    return "\n".join(o)+"\n"
open("fast.lib","w").write(lib("fast",1.10,-40.0,0.70,1.6))   # best-case: low delay, high leakage
open("slow.lib","w").write(lib("slow",0.95,125.0,1.65,0.5))   # worst-case: high delay, low leakage
print("wrote fast.lib + slow.lib")
