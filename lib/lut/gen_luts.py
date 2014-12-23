#!/usr/bin/env python
# Generate trig and reciprocal luts
import sys
import io
import math
from os.path import *
from struct import *

def deg2rad(a):
    return a*math.pi/180.0

def round(x):
    if x > 0.0:
        return math.floor(x + 0.5)
    else:
        return math.ceil(x - 0.5)

def sin_lut(ofile, wave_length, amplitude):
    
    deg_to_fixed = 360.0/wave_length # reduce wavelength

    for i in range(0, wave_length):
        t = math.sin(i * deg2rad(deg_to_fixed))*amplitude
        if t > amplitude-1:
            t = amplitude-1 # avoid overflow to negative
        t = int(round(t))
        #out_buffer = 'db {0}\n'.format(t)
        #ofile.write(out_buffer)
        if i % 8:
            ofile.write(', {0}'.format(t))
        else:
            ofile.write('\ndb {0}'.format(t))

#def div_lut(ofile, length, datatype):
    
def main():
    out_file = io.open('sin_lut.asm', 'wb')

    out_file.write('// 8.8 fixed point sine table\n'
            'scope sin: {\n')
    sin_lut(out_file, 1<<8, 1<<7)
    out_file.write('\n}\n')

    out_file.close()
        
if __name__ == '__main__':
    main()

