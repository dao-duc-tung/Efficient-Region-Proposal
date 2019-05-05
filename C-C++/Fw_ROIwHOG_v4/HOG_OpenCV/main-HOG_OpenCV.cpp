#include<opencv2/core/core.hpp>
#include<opencv2/highgui/highgui.hpp>
#include<opencv2/imgproc/imgproc.hpp>
#include<opencv2/objdetect/objdetect.hpp>

#include<iostream>
#include<conio.h>           // may have to modify this line if not using Windows
#include <iomanip>
#include <numeric>

#include"..\Core_Code\HOG.h"
#include"..\Core_Code\fileGettor.h"

#include <cstring>
#include <regex>
using namespace cv;

HOG hog = HOG();
string pIn, pOut, p1, p2;

string getExt(const string filename){
	size_t p=filename.find_last_of(".");
	return filename.substr(p+1,filename.size()-p-1);
}
string rmExt(const string filename){
	size_t p=filename.find_last_of(".");
	return filename.substr(0,p);
}

void doJob2(int hog_mode){

	if(hog_mode == DESVEC_DEFAULT){
		pOut = "C:/TUNGDD/Code/zexp/output_HOG_MODE_1/";
	}else if(hog_mode == DESVEC_FROMFILE){
		pOut = "C:/TUNGDD/Code/zexp/output_HOG_MODE_2/";
	}

	//run
	hog.given_roi = 24815;
	vector<int> TP, FP, FN, TN, NUM_PED, MISS_PED;
	vector<float> MISSRATE, RECALL, PRECISION, FPR;
	vector<std::pair<Rect, float>> ROI_SET;
	FileGettor fg(pIn.c_str());
	vector<string> file_list=fg.getFileList();
	vector<float> thresholdList;

	float STEP = (float)8 / NUM_POINT_OF_CURVE;
	for(int t=0; t<NUM_POINT_OF_CURVE; t++){
		thresholdList.push_back(t*STEP);
	}

	for(int t=0; t<thresholdList.size(); t++){
		hog.finalThreshold = thresholdList[t];
		for (int i=4; i<file_list.size(); i+=4)
		{
			if(getExt(file_list[i]).compare("png") != 0) continue;
			cout<<"\n"<<t<<" "<<file_list[i]<<"...\n";
			//p1 = pIn + file_list[i-1];
			p2 = pIn + file_list[i];

			vector<Rect> detectedRect = hog.detectMultiScaleHOG(p2);
			hog.given_roi = 24815;
			hog.evaluateHOG_v3(p2, detectedRect, ReadPed::getPed(p2, hog.pLabel, DEVIATE_HOG_MODE));

			TP.push_back(hog.tp);
			FP.push_back(hog.fp);
			FN.push_back(hog.fn);
			TN.push_back(hog.tn);

			// ROI + HOG_OpenCV && HOG_OpenCV
			imwrite(pOut+file_list[i], hog.outImg);
		}

		//evaluate RECALL, PREC, FPR, AVG_TEMPLATE
		int TP_SUM=accumulate(TP.begin(), TP.end(), 0);
		int FP_SUM=accumulate(FP.begin(), FP.end(), 0);
		int TN_SUM=accumulate(TN.begin(), TN.end(), 0);
		int FN_SUM=accumulate(FN.begin(), FN.end(), 0);

		float RECALL_ALL = (float)TP_SUM/(TP_SUM+FN_SUM)*100;
		float PREC_ALL = (float)TP_SUM/(TP_SUM+FP_SUM)*100;
		float FPR_ALL = (float)FP_SUM/(FP_SUM+TN_SUM)*100;

		//save 1 point
		RECALL.push_back(RECALL_ALL);
		PRECISION.push_back(PREC_ALL);
		FPR.push_back(FPR_ALL);
	}

	//save evaluate result
	ofstream myfile;
	myfile.open (pOut+"evaluation.txt");
	for(int t=0; t<RECALL.size(); t++){
		myfile<<RECALL[t]<<" "<<PRECISION[t]<<" "<<FPR[t]<<" "<<24815<<endl;
	}
	myfile.close();
}

void main(){
	pIn = "C:/TUNGDD/Code/zexp/src_ETHZ/";

	doJob2(DESVEC_FROMFILE);
}