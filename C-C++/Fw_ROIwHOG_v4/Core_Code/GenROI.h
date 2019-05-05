#ifndef GEN_ROI_H
#define GEN_ROI_H

#include<opencv2/core/core.hpp>
#include<opencv2/highgui/highgui.hpp>
#include<opencv2/imgproc/imgproc.hpp>
#include<opencv2/objdetect/objdetect.hpp>
#include<iostream>
#include<conio.h> 
#include<thread>
#include<fstream>
 
using namespace std;
using namespace cv;

class GenROI {
public: 
	int fn, num_ped, miss_ped, num_true_roi, num_roi, tp, fp, tn, given_roi, prob_func;
	string pLabel;
	Mat outImg, movingArea, transVectorImg;
	vector<std::pair<Rect, float>> pROI, nROI;
};

#endif