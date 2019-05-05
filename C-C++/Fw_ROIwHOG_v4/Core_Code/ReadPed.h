#ifndef READ_PED_H
#define READ_PED_H

#include<opencv2/core/core.hpp>
#include<opencv2/highgui/highgui.hpp>
#include<opencv2/imgproc/imgproc.hpp>
#include<opencv2/objdetect/objdetect.hpp>
#include<iostream>
#include<conio.h> 
#include<fstream>

using namespace std;
using namespace cv;

#define ROWS_READ_PED 480
#define COLS_READ_PED 640
#define THRESH_PEDCOOR 0 //64*128/7
#define DEVIATE_ROI_MODE 0 //20
#define DEVIATE_HOG_MODE 0 //20
#define NEAR_BOUNDARY 0 //3
#define PED_RATIO 0 //0.36

#define OVERLAP_ROI 0.7 //
#define OVERLAP_HOG 0.5 //

class ReadPed{
private:
	static int DEVIATE;
	static string label_ETHZ;
public:
	ReadPed();
	// get coordinate of pedestrian
	static vector<Rect> getPed(string img, string pLabel, int deviate);
	static vector<Rect> getROIsFromFile(string roiPath);
	static int getROIswScoreFromFile(string roiPath, float threshold, vector<std::pair<Rect, float>> &pROI, vector<std::pair<Rect, float>> &nROI);
	static string saveROIsToFile(string pOut, string pImg, vector<std::pair<Rect, float>> pROI, vector<std::pair<Rect, float>> nROI);
	static string saveROIsToFile(string pOut, string pImg, vector<std::pair<Rect, float>> pROI);
	// evaluate ROI
	static bool evaluateROI(Rect roi, Rect ped, float IoU);
	static float evaluateROI(Rect roi, Rect ped);
	static bool evaluateWhollyEnclosedPed(Rect roi, Rect ped);
private:
	static string getExt(const string filename);
	static string rmExt(const string filename);
	static string getName(const string filePath);
	// ver3: read ped coor for ETHZ Dataset
	static vector<Rect> getPedFromETHZ(string img);
	// allow a deviation
	static vector<Rect> deviatePed(vector<Rect> Ped, int deviate);
};

#endif