call "C:\Program Files\Microsoft Visual Studio 9.0\VC\vcvarsall.bat" x86
"C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v4.1\bin\nvcc.exe" -ptx --machine 32  %1
