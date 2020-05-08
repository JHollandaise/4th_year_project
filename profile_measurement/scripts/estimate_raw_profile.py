""" This is a janky script that I wrote in the summer 2019 to convert jank
online laser profilometer video into jank profile data.
It truly is a mess, and has no functions, classes or organisation of any kind.
But it works.
Also for some reason there is this one and then another for high def video
which I cannot remember why
"""

import numpy as np
import cv2
from cython_functions import compute_profile

import scipy.io as sio

# GLOBALS ---- TEMPORARY
fps = 120.0

lower_bound = 50   # 100 for 720p
upper_bound = 700   # 400 for 720

left_bound = 50    # 140 for 720p
right_bound = 1100  # 980 for 720p

channel_gap = 35    # 35 for 720p

height_thresh = 460     # 200 for 720p

intensity_thresh = 10

vid_name = "dropped_stitch"

cap = cv2.VideoCapture(vid_name + '.mp4')
width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH) + 0.5)
height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT) + 0.5)

size = (width, height)
fourcc = cv2.VideoWriter_fourcc(*'mp4v')
out = cv2.VideoWriter(vid_name + '_anno.mp4', fourcc, fps, size)

length = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
mean_height = np.empty([width,length])

# skip to frame
# cap.set(cv2.CAP_PROP_POS_FRAMES, 100)
frame_count = 0
while cap.isOpened():
    ret, frame = cap.read()
    if ret:
        frame_count+=1

        # threshold for laser (green channel - blue channel)
        # TODO: move into the compute_profile function as an optimisation
        grayscale = frame[:,:,1]-frame[:,:,2]
        # remove weird jpeg compression jank
        # TODO: investigate why this happens
        grayscale[grayscale>=240] = 0

        # calculate laser profile
        mean_height[:,frame_count-1] = np.array(compute_profile(lower_bound, upper_bound,
                                               intensity_thresh, grayscale))



        for x in range(frame.shape[1]):
            for y in range(-2, 3):
                # draw profile line to image
                frame[int(mean_height[x,frame_count-1] + y)][x] = 0
                # draw height threshold
                frame[height_thresh + y][x] = (0, 255, 255)

        for y in range(lower_bound, upper_bound):
            for x in range(-1, 2):

                # draw left and right boundaries
                frame[y][x + left_bound] = (255, 0, 0)
                frame[y][x + right_bound] = (255, 0, 0)

        out.write(frame)

        # cv2.imshow('frame', frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    else:
        break

cap.release()
out.release()
cv2.destroyAllWindows()

# save to .mat file
sio.savemat(vid_name +".mat", {vid_name:mean_height})
