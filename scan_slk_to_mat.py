"""
This script accepts a top level directory containing a set of scanned .slk
files, which will be converted into a single .mat (MATLAB array) file
containing all of the scan data.

call the script in this way
python3 scan_slk_mat.py t/l/d speed(mm/sec) x_gap(mm)
    2nd arg movement speed of y axis stepper during scan (so gap is computed
    as speed/10; laser records a profile every 10th of a second)
"""

import sylk_parser
import sys
import os
import scipy.io as sio
import numpy

## below is the structue of the folders/files
#   date_id
#   |
#   \-x_offset
#     |
#     \-new_####.slk

## eg
#   200220_00 (scan on the 20th feb 2020, of sample id 00)
#   |
#   \-00 (first line of the scan, so no x-axis offset)
#   | |
#   | |-new_0001.slk (y-axis is assumed to be = 0mm here)
#   | |-new_0002.slk (1st offset taken some ymm from new_0001)
#   | |-new_0003.slk
#   | \-new_etcetc.slk
#   \-01 (1st offset taken some xmm away from 00 scan, so offset applied)
#     |
#     |-new_0001.slk (etc etc)

SCANS_PER_SECOND = 10

def main():
    # ensure user has specified a filename (2 arguements)
    if len(sys.argv) < 2:
        print("no top-level folder given")
        return

    # now validate folder name
    if not os.path.isdir(sys.argv[1]):
        print("invalid folder name given")
        return

    # assign folder
    # eg: '/Users/.../.../.../200220_00'
    top_level_path = os.path.realpath(sys.argv[1])
    # assign name for .mat file (is the folder name)
    # eg: '200220_00'
    mat_array_name = os.path.split(top_level_path)[1]


    ## now see if the user has given the other optional parameters
    
    # y-stepper speed
    if len(sys.argv) < 3:
        print("No y direction scan speed given")
        return


    # assign scan speed
    try:
        y_scan_speed = float(sys.argv[2])
    except:
        print("Invalid scan speed given (float needed)")
        return

    # compute y offset distance
    y_offset_distance = y_scan_speed/SCANS_PER_SECOND
    
    # x offset distance
    if len(sys.argv) < 4:
        print("No x offset given")
        return


    # assign x offset distance between scan lengths
    try:
        x_offset_distance = float(sys.argv[3])
    except:
        print("Invalid x offset given (float needed)")
        return
    
    

    # now get the list of subfolder names in the TLD
    scan_folder_list = []
    for name in os.listdir(top_level_path):
        if os.path.isdir(os.path.join(top_level_path,name)):
            scan_folder_list.append(name)
    scan_folder_list.sort()

    # DEBUG: print sfl
    # print(scan_folder_list)


    # BEGIN PRIMARY CONVERSION PROCEDURE

    data_array = []

    current_x_offset = 0
    # iterate through the folders
    for scan_folder in scan_folder_list:

        current_y_position = 0 
        # now get the list of scan file names in the scan folder
        scan_file_list = []
        for name in os.listdir(os.path.join(top_level_path,scan_folder)):
            # check if a file and has extension .slk
            if os.path.isfile(os.path.join(top_level_path,scan_folder,name)):
                scan_file_list.append(name)
        scan_file_list.sort()
        
        # DEBUG: print sfl
        # print(scan_file_list)

        # iterate though the scan files
        for scan_file in scan_file_list:
            
            # parse scan file
            parser = sylk_parser.SylkParser(os.path.join(top_level_path,scan_folder,scan_file))

            # iterate through lines in parsed file
            for data_line in parser.sylk_handler.data:

                current_x_position = float(data_line[0]) + current_x_offset
                current_z_posistion = float(data_line[1])

                data_array.append([current_x_position,current_y_position,current_z_posistion])

            current_y_position += y_offset_distance

        current_x_offset += x_offset_distance

    
    data_array_nump = numpy.array(data_array)
    sio.savemat(top_level_path + "/" + mat_array_name + ".mat", {mat_array_name:data_array})



    

    


if __name__ == "__main__":
    main()
