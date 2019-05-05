#include<opencv2/core/core.hpp>
#include<opencv2/highgui/highgui.hpp>
#include<opencv2/imgproc/imgproc.hpp>
#include<opencv2/objdetect/objdetect.hpp>

#include<iostream>
#include<conio.h>           // may have to modify this line if not using Windows
#include <numeric>

#include"..\Core_Code\fileGettor.h"
#include"General_Eval.h"

using namespace cv;

string pIn, pOut, p1, p2, src_ETHZ;

//func1: Gen all possible ROIs (without limitting the num of ROI and score of them) in the whole dataset, save to File
void doFunc1(string inPath, string outPath, int MODE){
	pIn = inPath;
	pOut = outPath;
	cout << pOut << endl;

	//run
	FileGettor fg(pIn.c_str());
	vector<string> file_list=fg.getFileList();
	for (int i=4; i<file_list.size(); i+=4)
	{
		if(General_Eval::getExt(file_list[i]).compare("png") != 0) continue;
		cout<<"\n"<<file_list[i]<<"...\n";
		p1 = pIn + file_list[i-1];
		p2 = pIn + file_list[i];

		General_Eval::generateROI(p1, p2, MODE);
		General_Eval::saveROIsToFile(pOut, p2, General_Eval::pROI, General_Eval::nROI);
		General_Eval::resetROISet();
	}
}

//func2: evaluating the ROI set
// Load ROI from file, threshold the score of ROI to generate the ROI set for each image in dataset
// then evaluating them to get 1 point on ROC & PR Curve, or detection rate following by the num of DW
void doFunc2(string roiPathFolder){
	pIn = roiPathFolder;
	pOut = roiPathFolder;
	cout << pIn << endl;

	//run
	vector<float> RECALL, PRECISION, FPR, AVG_TEMPLATE;
	FileGettor fg(pIn.c_str());
	vector<string> file_list=fg.getFileList();
	vector<float> thresholdList = General_Eval::getThresholdList(pIn);

	for(int t=0; t<thresholdList.size(); t++){
		vector<int> TP, FP, FN, TN;
		vector<std::pair<Rect, float>> ROI_SET;
		for (int i=0; i<file_list.size(); i++)
		{
			if(file_list[i].compare("evaluation.txt") == 0) continue;
			if(General_Eval::getExt(file_list[i]).compare("txt") != 0) continue;
			cout<<"\n"<<t<<" "<<file_list[i]<<"...\n";
			p2 = pIn + file_list[i];

			//get pROI, nROI
			vector<pair<Rect, float>> pROI, nROI;
			General_Eval::getROIswScoreFromFile(p2, thresholdList[t], pROI, nROI);

			//eval them
			string imgPath = src_ETHZ+General_Eval::getOriImgNameFromRoiPath(p2)+".png";
			General_Eval::evaluateROI_v2(imgPath, pROI, nROI);

			ROI_SET.insert(ROI_SET.end(), pROI.begin(), pROI.end());
			TP.push_back(General_Eval::tp);
			FP.push_back(General_Eval::fp);
			FN.push_back(General_Eval::fn);
			TN.push_back(General_Eval::tn);

			string ROIName = General_Eval::getOriImgNameFromRoiPath(p2)+"-ROI."+General_Eval::getExt(imgPath);
			imwrite(pOut+ROIName, General_Eval::outImgROI);
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
		AVG_TEMPLATE.push_back((float)ROI_SET.size()/TP.size());
	}

	//save evaluate result
	ofstream myfile;
	myfile.open(pOut+"evaluation.txt");
	for(int t=0; t<RECALL.size(); t++){
		myfile<<RECALL[t]<<" "<<PRECISION[t]<<" "<<FPR[t]<<" "<<AVG_TEMPLATE[t]<<endl;
	}
	myfile.close();
}

//func3: evaluating the HOG result
// Load ROI from file, threshold the score of ROI to generate the ROI set for each image in dataset
// pass ROI set through HOG to get the pedestrian detection result
// then evaluating them to get 1 point on PR Curve, or detection rate following by the num of DW
void doFunc3(string roiPathFolder, string outROIwHOGFolder){
	pIn = roiPathFolder;
	pOut = outROIwHOGFolder;
	cout << pIn << endl;

	//run
	vector<float> RECALL, PRECISION, FPR, AVG_TEMPLATE;
	FileGettor fg(pIn.c_str());
	vector<string> file_list=fg.getFileList();
	vector<float> thresholdList = General_Eval::getThresholdList(pIn);

	for(int t=0; t<thresholdList.size(); t++){
		vector<int> TP, FP, FN, TN;
		vector<std::pair<Rect, float>> ROI_SET;
		for (int i=0; i<file_list.size(); i++)
		{
			if(file_list[i].compare("evaluation.txt") == 0) continue;
			if(General_Eval::getExt(file_list[i]).compare("txt") != 0) continue;
			cout<<"\n"<<t<<" "<<file_list[i]<<"...\n";
			p2 = pIn + file_list[i];

			//get pROI, nROI
			vector<pair<Rect, float>> pROI, nROI;
			General_Eval::given_roi = General_Eval::getROIswScoreFromFile(p2, thresholdList[t], pROI, nROI);

			string imgPath = src_ETHZ+General_Eval::getOriImgNameFromRoiPath(p2)+".png";

			//HOG
			General_Eval::hogForScoredROIs(imgPath, pROI, nROI);

			ROI_SET.insert(ROI_SET.end(), pROI.begin(), pROI.end());
			TP.push_back(General_Eval::tp);
			FP.push_back(General_Eval::fp);
			FN.push_back(General_Eval::fn);
			TN.push_back(General_Eval::tn);

			string ROIName = General_Eval::getOriImgNameFromRoiPath(p2)+"-HOG."+General_Eval::getExt(imgPath);
			imwrite(pOut+ROIName, General_Eval::outImgHOG);
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
		AVG_TEMPLATE.push_back((float)ROI_SET.size()/TP.size());
	}

	//save evaluate result
	ofstream myfile;
	myfile.open(pOut+"evaluation.txt");
	for(int t=0; t<RECALL.size(); t++){
		myfile<<t<<" "<<thresholdList[t]<<" "<<RECALL[t]<<" "<<PRECISION[t]<<" "<<FPR[t]<<" "<<AVG_TEMPLATE[t]<<endl;
	}
	myfile.close();
}

//func4: generate video from LOEWENPLATZ dataset
void doFunc4(string inPath, string outPath){
	pIn = inPath;
	pOut = outPath;

	float threshold = 1.93392;
	FileGettor fg(pIn.c_str());
	vector<string> file_list=fg.getFileList();
	for (int i=1; i<file_list.size(); i++){
		if(General_Eval::getExt(file_list[i]).compare("png") != 0) continue;
		cout<<"\n"<<file_list[i]<<"...\n";
		p1 = pIn + file_list[i-1];
		p2 = pIn + file_list[i];

		//generate ROI
		General_Eval::generateROI(p1, p2, PROPOSAL_MODE);
		//just HOG on pROI
		General_Eval::hogForScoredPROIs(p2, General_Eval::pROI, threshold);

		string ROIName = General_Eval::getOriImgNameFromRoiPath(p2)+"-HOG."+General_Eval::getExt(p2);
		imwrite(pOut+ROIName, General_Eval::outImgHOG);
	}
}

void createVideo(string inPath, string outPath){
	pIn = inPath;
	pOut = outPath;

	FileGettor fg(pIn.c_str());
	vector<string> file_list=fg.getFileList();
	vector<Mat> images;

	for(int i=0; i<file_list.size(); i++){
		if(General_Eval::getExt(file_list[i]).compare("png") != 0) continue;
		images.push_back(imread(pIn + file_list[i]));
	}

	VideoWriter outVideo;
	outVideo.open(pOut+"outVideo.avi", CV_FOURCC('P','I','M','1'), 20, Size(images[0].cols, images[0].rows), true);
	if (!outVideo.isOpened()){
        cout  << "Could not open the output video for write: "<< endl;
        return;
    }

    for(int i=0; i<images.size(); i++){
        outVideo << images[i];
    }

    cout << "Finished writing" << endl;
}

int main(){
	src_ETHZ = "C:/TUNGDD/Code/zexp/src_ETHZ/";
	
	string out_ROI_OF = "C:/TUNGDD/Code/zexp/out_ROI_OF/";
	string out_ROI_Proposal = "C:/TUNGDD/Code/zexp/out_ROI_Proposal/";
	string out_ROI_Ver = "C:/TUNGDD/Code/zexp/out_ROI_Ver/";
	string out_ROI_XCorr = "C:/TUNGDD/Code/zexp/out_ROI_XCorr/";

	string out_ROIwHOG_OF = "C:/TUNGDD/Code/zexp/out_ROIwHOG_OF/";
	string out_ROIwHOG_Proposal = "C:/TUNGDD/Code/zexp/out_ROIwHOG_Proposal/";
	string out_ROIwHOG_Ver = "C:/TUNGDD/Code/zexp/out_ROIwHOG_Ver/";
	string out_ROIwHOG_XCorr = "C:/TUNGDD/Code/zexp/out_ROIwHOG_XCorr/";

	string output_image_seq = "C:/TUNGDD/Code/zexp/output_image_seq/";

	//doFunc1(src_ETHZ, out_ROI_OF, OF_MODE);
	//doFunc1(src_ETHZ, out_ROI_Proposal, PROPOSAL_MODE);
	//doFunc1(src_ETHZ, out_ROI_XCorr, XCORR_MODE);
	//doFunc1(src_ETHZ, out_ROI_Ver, VER_MODE);

	//doFunc2(out_ROI_OF);
	//doFunc2(out_ROI_Proposal);
	//doFunc2(out_ROI_Ver);
	//doFunc2(out_ROI_XCorr);

	//doFunc3(out_ROI_OF, out_ROIwHOG_OF);
	//doFunc3(out_ROI_Proposal, out_ROIwHOG_Proposal);
	//doFunc3(out_ROI_XCorr, out_ROIwHOG_XCorr);
	//doFunc3(out_ROI_Ver, out_ROIwHOG_Ver);

	//VIETNAM
	//doFunc1(src_ETHZ, out_ROI_Proposal, PROPOSAL_MODE);
	//doFunc3(out_ROI_Proposal, out_ROIwHOG_Proposal);

	//doFunc4(src_ETHZ, output_image_seq);
	createVideo(src_ETHZ, src_ETHZ);

	return 0;
}