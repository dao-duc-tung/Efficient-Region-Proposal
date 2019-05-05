#ifndef HOG_H
#define HOG_H

#include<opencv2/core/core.hpp>
#include<opencv2/highgui/highgui.hpp>
#include<opencv2/imgproc/imgproc.hpp>
#include<opencv2/objdetect/objdetect.hpp>
#include<iostream>
#include<conio.h> 
#include<thread>
#include<fstream>

#include"ReadPed.h"

using namespace cv;

#define DESVEC_DEFAULT 0
#define DESVEC_FROMFILE 1

#define NUM_POINT_OF_CURVE 10

class HOG{
private:
	clock_t s, f;
	
	float scale;
	vector<float> desVecDefault;
	vector<float> desVecFromFile;
public:
	string pLabel;
	double hitThreshold, finalThreshold;
	int fn, num_ped, num_true_roi, num_roi, tp, fp, tn, given_roi;
	Mat outImg;

	HOG();
	void hogForImage(string img);
	void hogForScoredROIs(string img, vector<std::pair<Rect, float>> pROI, vector<std::pair<Rect, float>> nROI);
	void hogWithoutEval(string img, vector<std::pair<Rect, float>> pROI, float threshold);
	void hogForEBs(string img, vector<Rect> edgeBoxes);
	void hogForROIs(string img, vector<Rect> rois);
	vector<Rect> detectHOG(string img);
	vector<Rect> detectHOG(Mat ori);
	vector<Rect> detectMultiScaleHOG(string img);

	Mat evaluateHOG_v3(string img, vector<Rect> detectedRect, vector<Rect> pedCoor);
	Mat displayRectInImg(vector<Rect> detectedRect, Mat roi);
private:
	vector<float> getDescriptorVector(int type);
	vector<float> getDescriptorVectorFromFile(const string& vectorFile);
};

#endif