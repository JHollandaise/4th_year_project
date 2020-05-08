import os
_src = "../roller_mounted/FBS_06_FBN_04/lit_surface/"
_ext = ".jpg"
files = os.listdir(_src)
files.sort()
for i,filename in enumerate(files):
    if filename.endswith(_ext):
        os.rename(_src+filename, _src + 'IMG_' + str(i+1).zfill(4)+_ext)
        # print(filename)
