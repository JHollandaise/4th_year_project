import cv2
import numpy as np

# for image data visualisation
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
from matplotlib import colors

# load imag into openCV frame
# original size (4160,3120)
# 538±143 ms EXPENSIVE!!!!
img = cv2.imread('adjst.tif')

# 14.6±.32 ms (can be removed)
img = cv2.cvtColor(img,cv2.COLOR_BGR2RGB)
img = cv2.resize(img,(4160//32,3120//32))

# 125 ms ± 1.67 ms (also fairly expensive)
img_hsv = cv2.cvtColor(img, cv2.COLOR_RGB2HSV)


# plt.imshow(img)
# plt.show()

# 3D plot
h, s, v = cv2.split(img_hsv)

pixel_colors = img.reshape((np.shape(img)[0]*np.shape(img)[1], 3))
norm = colors.Normalize(vmin=-1.,vmax=1.)
norm.autoscale(pixel_colors)
pixel_colors = norm(pixel_colors).tolist()

fig = plt.figure("Partial Cement")
axis = fig.add_subplot(1, 1, 1, projection="3d")

axis.scatter(h.flatten(), s.flatten(), v.flatten(), facecolors=pixel_colors, marker=".")
axis.set_xlabel("Hue")
axis.set_ylabel("Saturation")
axis.set_zlabel("Value")
plt.show()

#2D plot
# h, s, v = cv2.split(img_hsv)
#
# pixel_colors = img.reshape((np.shape(img)[0]*np.shape(img)[1], 3))
# norm = colors.Normalize(vmin=-1.,vmax=1.)
# norm.autoscale(pixel_colors)
# pixel_colors = norm(pixel_colors).tolist()
#
# fig = plt.figure("Partial Cement")
# axis = fig.add_subplot(1, 1, 1)
#
# axis.scatter(s.flatten(), v.flatten(), facecolors=pixel_colors, marker=".")
# axis.set_xlabel("Saturation")
# axis.set_ylabel("Value")
# plt.show()
#
# # 144ms
# mask1 = cv2.inRange(img_hsv, (100,0,0),(255,255,255))
# # mask2 = cv2.inRange(img_hsv, (10,18,200),(30,70,255))
# # mask3 = cv2.inRange(img_hsv, (10,24,160),(30,70,255))
# # mask4 = cv2.inRange(img_hsv, (10,30,130),(30,70,255))
# # 50.4 ms
# mask = mask1 #+ mask2 + mask3 + mask4
#

plt.imshow(mask)
plt.show()
