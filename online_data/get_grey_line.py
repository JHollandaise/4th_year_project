import numpy as np
import cv2
from cython_functions import compute_profile
from scipy.signal import find_peaks

# GLOBALS ---- TEMPORARY
fps = 120.0

upper_limit = 225

VIDEO_NAME = 'underfill'

# what vid file to get nominal profile distribution from
cap = cv2.VideoCapture(VIDEO_NAME+'.mp4')
width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH) + 0.5)
height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT) + 0.5)

profile = None

frame_count = 0
while cap.isOpened():
    ret, frame = cap.read()
    if ret:
        frame_count += 1

        # convert video to intensity value
        grayscale = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)


        # store profile data
        if profile is None:
            profile = [grayscale[upper_limit][:]]
        else:
            profile = np.append(profile, [grayscale[upper_limit][:]], axis=0)

    else:
        break
print(profile)
np.savetxt(VIDEO_NAME+'_greyline.csv', profile, delimiter=',')

cv2.destroyAllWindows()
