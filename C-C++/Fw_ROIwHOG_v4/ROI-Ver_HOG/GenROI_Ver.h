#ifndef GEN_ROI_VER_H
#define GEN_ROI_VER_H

#include<opencv2/core/core.hpp>
#include<opencv2/highgui/highgui.hpp>
#include<opencv2/imgproc/imgproc.hpp>
#include<opencv2/objdetect/objdetect.hpp>
#include<iostream>
#include<conio.h> 
#include<thread>
#include<fstream>

#include"..\Core_Code\ReadPed.h"
#include"..\Core_Code\GenROI.h"

using namespace cv;

class GenROI_Ver : public GenROI {
private:
	static int THRES_GRAD;

	static int MIN_WIDTH, MIN_HEIGHT;
	static int MAX_WIDTH, MAX_HEIGHT;
	static int STEP_WIDHT, STEP_HEIGHT;
	static int MIN_PIXEL_ROI, MIN_PIXEL_LEG;
	static int ROW_STEP_WINDOW, COL_STEP_WINDOW;
	static int NUM_ROI;
	static float THRES_NMS_ROI;

public:
	GenROI_Ver();
	vector<std::pair<Rect, float>> doMainJob(string sI1, string sI2);
private:
	vector<std::pair<Rect, float>> doMainJob(string sI);
	void generateROI(Mat I, vector<std::pair<Rect, float>>& pROI, vector<std::pair<Rect, float>>& nROI);
	void nms(vector<std::pair<Rect, float>> ROIs, float overlapThresh, vector<std::pair<Rect, float>>& filteredROI, vector<std::pair<Rect, float>>& removedROI);
	vector<std::pair<Rect, float>> evaluateROI_v2(string img, vector<std::pair<Rect, float>> pROI, vector<std::pair<Rect, float>> nROI, vector<Rect> PedCoor);

	void displayRect(Mat presentFrame, vector<Rect> ROIs);
	int getVanishingLine(string pLabel);
	void gradient(Mat input, Mat& magnitude, Mat& vGrad, Mat& hGrad, int thres);
};

#endif