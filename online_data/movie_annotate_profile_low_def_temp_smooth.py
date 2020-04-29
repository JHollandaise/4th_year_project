import numpy as np
import cv2
from cython_functions import compute_profile
from scipy.signal import find_peaks_cwt
from scipy.signal import find_peaks
from scipy.signal import savgol_filter

# GLOBALS ---- TEMPORARY
fps = 120.0/50

lower_bound = 50   # 100 for 720p
upper_bound = 700   # 400 for 720

left_bound = 140    # 140 for 720p
right_bound = 980  # 980 for 720p

channel_gap = 32    # 35 for 720p

height_thresh = 200     # 200 for 720p

intensity_thresh = 150

cap = cv2.VideoCapture('test_vid3.MP4')

width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH) + 0.5)
height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT) + 0.5)

size = (width, height)
fourcc = cv2.VideoWriter_fourcc(*'mp4v')
out = cv2.VideoWriter('annotated_smooth.mp4', fourcc, fps, size)

# skip to frame
cap.set(cv2.CAP_PROP_POS_FRAMES, 500)

while cap.isOpened():
    mean_heights = []
    frame = None
    for _ in range(50):
        ret, frame = cap.read()
        if ret:

            # calculate laser profile
            mean_height = np.array(compute_profile(lower_bound, upper_bound,
                                                   intensity_thresh, frame[:,:,1]))

            mean_heights.append(mean_height)
        else:
            break
    else:
        avg_height = np.average(mean_heights,axis=0)
        # estimate channel peak positions
        peaks, _ = find_peaks(-avg_height[left_bound:right_bound],
                              height=(-upper_bound, -lower_bound),
                              distance=channel_gap)

        # define wavelet width convolutions
        widths = np.arange(38, 50)
        # peaks = find_peaks_cwt(-mean_height[140:980], widths, max_distances=widths/2, )

        # gaps = [peaks[i] - peaks[i - 1] for i in range(1, len(peaks))]
        # print(np.median(gaps))

        for x in range(frame.shape[1]):
            for y in range(-2, 3):
                # draw profile line to image
                frame[int(avg_height[x] + y)][x] = 0
                # draw height threshold
                frame[height_thresh + y][x] = (0, 255, 255)

        for y in range(lower_bound, upper_bound):
            for x in range(-1, 2):

                # draw left and right boundaries
                frame[y][x + left_bound] = (255, 0, 0)
                frame[y][x + right_bound] = (255, 0, 0)

                # draw found peaks
                for peak in peaks:
                    if avg_height[peak + left_bound] < height_thresh:
                        frame[y][peak + x + left_bound] = (0, 255, 0)
                    else:
                        frame[y][peak + x + left_bound] = (0, 0, 255)

        out.write(frame)

        cv2.imshow('frame', frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
        continue
    break

cap.release()
out.release()
cv2.destroyAllWindows()
