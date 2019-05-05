#ifndef GENERAL_EVAL_H
#define GENERAL_EVAL_H

#include<opencv2/core/core.hpp>
#include<opencv2/highgui/highgui.hpp>
#include<opencv2/imgproc/imgproc.hpp>
#include<opencv2/objdetect/objdetect.hpp>
#include<iostream>
#include<conio.h> 
#include<thread>
#include<fstream>

#include"..\Core_Code\fileGettor.h"
#include"..\Core_Code\ReadPed.h"
#include"..\Core_Code\HOG.h"
#include"..\ROI-OF_HOG\GenROI_OF.h"
#include"..\ROI-Proposal_HOG\GenROI_Proposal.h"
#include"..\ROI-Ver_HOG\GenROI_Ver.h"
#include"..\ROI-XCorr_HOG\GenROI_XCorr.h"

#define OF_MODE 1
#define PROPOSAL_MODE 2
#define VER_MODE 3
#define XCORR_MODE 4

//#define NUM_POINT_OF_CURVE 19

using namespace cv;

class General_Eval{
private:
	static GenROI_OF genROI_OF;
	static GenROI_Proposal genROI_Proposal;
	static GenROI_Ver genROI_Ver;
	static GenROI_XCorr genROI_XCorr;
	static HOG hog;

public:
	static string pLabel;
	static vector<pair<Rect, float>> pROI, nROI;
	static Mat outImgHOG, outImgROI;

	static int tp, fp, tn, fn, given_roi, miss_ped, num_ped;

	General_Eval();
	static vector<float> getThresholdList(string roiPathFolder);
	static void generateROI(string sI1, string sI2, int MODE);
	static void saveROIsToFile(string pOut, string pImg, vector<std::pair<Rect, float>> pROI, vector<std::pair<Rect, float>> nROI);
	static int getROIswScoreFromFile(string roiPath, float threshold, vector<std::pair<Rect, float>> &pROI, vector<std::pair<Rect, float>> &nROI);
	static void evaluateROI_v2(string img, vector<pair<Rect, float>> pROI, vector<pair<Rect, float>> nROI);
	static void hogForScoredROIs(string img, vector<std::pair<Rect, float>> pROI, vector<std::pair<Rect, float>> nROI);
	static void hogForScoredPROIs(string img, vector<std::pair<Rect, float>> pROI, float threshold);

	static void resetROISet();

	static string getOriImgNameFromRoiPath(const string roiPath);
	static string getExt(const string filename);
	static string rmExt(const string filename);
};

#endif
