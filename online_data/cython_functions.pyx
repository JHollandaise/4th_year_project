"""Fast Cython implementation of laser line manipulation functions."""

import cython
import numpy as np

@cython.boundscheck(False)  # Deactivate bounds checking
@cython.wraparound(False)   # Deactivate negative indexing.
cpdef double[:]compute_profile(int lower_bound, int upper_bound, int threshold,
                               unsigned char [:, :] image):
    """calculate the mean laser line position between lower_bound and
    upper_bound.
    Laser light is considered to be pixels with intensity
    above threshold.
    ~1ms per frame
    """
    cdef int x, y, total_weight
    cdef unsigned char value
    cdef double [:] mean_height

    mean_height = np.zeros(image.shape[1])

    for x in range(mean_height.shape[0]):
        total_weight = 0
        for y in range(lower_bound, upper_bound):
            value = image[y, x]
            if value > threshold:
                mean_height[x] += y*value
                total_weight += value
        if total_weight > 0:
            mean_height[x] /= total_weight
        elif x>0:
            mean_height[x] = mean_height[x-1]
        else:
            mean_height[x] = 0

    return mean_height
