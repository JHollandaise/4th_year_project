from distutils.core import setup
from Cython.Build import cythonize

setup(name='Cython Functions',
      ext_modules=cythonize("cython_functions.pyx"))