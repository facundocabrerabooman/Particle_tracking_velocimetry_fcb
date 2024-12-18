%mcc -mv CenterFinding2D.m -a mCINREAD2.m -d /home/mbourgoi/LEM/PTV_LEM/
mcc -mv centers2rays.m -a findRays.m readCentersTxt.m -d /home/mbourgoi/LEM/PTV_LEM/
%mcc -mv mcin2h5All.m -a mcin2h5.m mCINREAD2.m -d /home/mbourgoi/LEM/PTV_LEM/
