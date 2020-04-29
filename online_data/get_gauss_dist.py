import numpy as np
import cv2
from cython_functions import compute_profile
from scipy.signal import find_peaks

# GLOBALS ---- TEMPORARY
fps = 120.0

lower_bound = 250   # 100 for 720p
upper_bound = 550   # 400 for 720

left_bound = 160    # 140 for 720p
right_bound = 1100  # 980 for 720p

channel_gap = 35    # 35 for 720p

height_thresh = 460     # 200 for 720p

intensity_thresh = 150

VIDEO_NAME = '190724-03_profile'

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

        # calculate  laser profile (using Cython for speedup)
        mean_height = np.array(compute_profile(lower_bound, upper_bound,
                                               intensity_thresh, grayscale))

        # store profile data
        if profile is None:
            profile = [mean_height]
        else:
            profile = np.append(profile, [mean_height], axis=0)

    else:
        break
print(profile)
np.savetxt(VIDEO_NAME+'.csv', profile, delimiter=',')

cv2.destroyAllWindows()
