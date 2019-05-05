#ifndef IGEN_ROI_H
#define IGEN_ROI_H

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

class IGenROI {
public: 
	int fn, num_ped, miss_ped, num_true_roi, num_roi, tp, fp, tn, given_roi, prob_func;
	string pLabel;
	Mat outImg, movingArea, transVectorImg;
	virtual vector<std::pair<Rect, float>> doMainJob(string sI1, string sI2) = 0;
};

#endif