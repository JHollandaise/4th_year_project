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

VIDEO_NAME = 'underfill'

cap = cv2.VideoCapture(VIDEO_NAME+'.mp4')
width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH) + 0.5)
height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT) + 0.5)

size = (width, height)
fourcc = cv2.VideoWriter_fourcc(*'mp4v')
out = cv2.VideoWriter(VIDEO_NAME+'_anno.mp4', fourcc, fps, size)

nominal_profile_dist = np.loadtxt(VIDEO_NAME+'_nominal_properties.csv',
                                  delimiter=',')

# get nominal peaks
nominal_peaks, _ = find_peaks(-nominal_profile_dist[0][left_bound:right_bound],
                                  height=(-upper_bound, -lower_bound),
                                  distance=channel_gap)


# skip to frame
cap.set(cv2.CAP_PROP_POS_FRAMES, 2500)
frame_count = 0
while cap.isOpened():
    ret, frame = cap.read()
    if ret:
        frame_count+=1


        grayscale = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

        # calculate laser profile
        mean_height = np.array(compute_profile(lower_bound, upper_bound,
                                               intensity_thresh, grayscale))

        # smooth height
        # mean_height = savgol_filter(mean_height, 11, 2)

        # estimate channel peak positions
        peaks, props = find_peaks(-mean_height[left_bound:right_bound],
                                  height=(-upper_bound, -lower_bound),
                                  distance=channel_gap)



        # define wavelet width convolutions
        # widths = np.arange(8, 11)
        # peaks = find_peaks_cwt(mean_height[left_bound:right_bound], widths)

        # gaps = [peaks[i] - peaks[i - 1] for i in range(1, len(peaks))]
        # print(np.median(gaps))


        for x in range(frame.shape[1]):
            for y in range(-2, 3):
                if (nominal_profile_dist[0][x] -
                    2*nominal_profile_dist[1][x]) < mean_height[x] < \
                        (nominal_profile_dist[0][x] + 2*nominal_profile_dist[
                            1][x]):
                    # draw profile line to image
                    frame[int(mean_height[x] + y)][x] = (255,0,0)
                else:
                    frame[int(mean_height[x] + y)][x] = (0, 0, 255)
                # draw height threshold
            for y in range(-1,2):
                frame[int(nominal_profile_dist[0][x] +
                          2*nominal_profile_dist[1][
                    x]+ y)][x] = (0, 255, 255)
                frame[int(nominal_profile_dist[0][x] -
                          2*nominal_profile_dist[1][
                    x] +y)][x] = (0, 255, 255)
                frame[int(nominal_profile_dist[0][x] + y)][x] = (255, 255, 255)

        for y in range(lower_bound, upper_bound):

            # draw left and right boundaries
            frame[y][left_bound] = (255, 0, 0)
            frame[y][right_bound] = (255, 0, 0)

            # draw found peaks
            for peak in peaks:
                    frame[y][peak + left_bound] = (255, 0, 255)
            for peak in nominal_peaks:
                frame[y][peak + left_bound] = (255, 255, 255)


        out.write(frame)

        cv2.imshow('frame', frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    else:
        break


cap.release()
out.release()
cv2.destroyAllWindows()
