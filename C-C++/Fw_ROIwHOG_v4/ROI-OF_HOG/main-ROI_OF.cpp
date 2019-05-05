#include<opencv2/core/core.hpp>
#include<opencv2/highgui/highgui.hpp>
#include<opencv2/imgproc/imgproc.hpp>
#include<opencv2/objdetect/objdetect.hpp>

#include<iostream>
#include<conio.h>           // may have to modify this line if not using Windows
#include<numeric>

#include"GenROI_OF.h"
#include"..\Core_Code\HOG.h"
#include"..\Core_Code\fileGettor.h"

using namespace cv;

GenROI_OF genROI = GenROI_OF();
HOG hog = HOG();
string pIn, pOut, name1, name2, p1, p2;

string getExt(const string filename){
	size_t p=filename.find_last_of(".");
	return filename.substr(p+1,filename.size()-p-1);
}
string rmExt(const string filename){
	size_t p=filename.find_last_of(".");
	return filename.substr(0,p);
}

void doROI_wHOG(){
	pOut = "C:/TUNGDD/Code/zexp/output_ROI_OF_HOG_1/";

	//run
	vector<int> TP, FP, FN, TN, NUM_PED, MISS_PED;
	vector<float> MISSRATE, RECALL, PRECISION, FPR;
	vector<std::pair<Rect, float>> ROI_SET;
	FileGettor fg(pIn.c_str());
	vector<string> file_list=fg.getFileList();

	for (int i=4; i<file_list.size()-1; i+=4)
	{
		if(getExt(file_list[i]).compare("png") != 0) continue;
		cout<<"\n"<<file_list[i]<<"...\n";
		p1 = pIn + file_list[i-1];
		p2 = pIn + file_list[i];

		// ROI + HOG_OpenCV
		genROI.doMainJob(p1, p2);
		hog.hogForScoredROIs(p2, genROI.pROI, genROI.nROI);
		ROI_SET.insert(ROI_SET.end(), genROI.pROI.begin(), genROI.pROI.end());

		// HOG_OpenCV || ROI + HOG_OpenCV
		TP.push_back(hog.tp);
		FP.push_back(hog.fp);
		FN.push_back(hog.fn);
		TN.push_back(hog.tn);
		NUM_PED.push_back(hog.num_ped);

		imwrite(pOut+file_list[i], hog.outImg);
		string ROIName = rmExt(file_list[i])+"-ROI."+getExt(file_list[i]);
		imwrite(pOut+ROIName, genROI.outImg);
		string MovingName = rmExt(file_list[i])+"-Moving."+getExt(file_list[i]);
		imwrite(pOut+MovingName, genROI.movingArea);
	}

	//evaluate RECALL, PREC, FPR, AVG_TEMPLATE
	int TP_SUM=accumulate(TP.begin(), TP.end(), 0);
	int FP_SUM=accumulate(FP.begin(), FP.end(), 0);
	int TN_SUM=accumulate(TN.begin(), TN.end(), 0);
	int FN_SUM=accumulate(FN.begin(), FN.end(), 0);
	int NUM_PED_SUM = accumulate(NUM_PED.begin(), NUM_PED.end(), 0);
	int MISS_PED_SUM = accumulate(MISS_PED.begin(), MISS_PED.end(), 0);
	float RECALL_ALL = (float)TP_SUM/(TP_SUM+FN_SUM)*100;
	float PREC_ALL = (float)TP_SUM/(TP_SUM+FP_SUM)*100;
	float FPR_ALL = (float)FP_SUM/(FP_SUM+TN_SUM)*100;

	int AVG_TEMPLATE = 0;
	int NUM_TEMPLATE_PER_TYPE[9] = {1,9,32,61,123,221,321,472,637};
	int TEMPLATE_TYPE = -1;
	int TOTAL_TEMPLATE = 0;
	for(int i=0; i<ROI_SET.size(); i++){
		int w = ROI_SET[i].first.width;
		switch (w)
		{
			case 64: TEMPLATE_TYPE=0; break;
			case 72: TEMPLATE_TYPE=1; break;
			case 80: TEMPLATE_TYPE=2; break;
			case 88: TEMPLATE_TYPE=3; break;
			case 96: TEMPLATE_TYPE=4; break;
			case 104: TEMPLATE_TYPE=5; break;
			case 112: TEMPLATE_TYPE=6; break;
			case 120: TEMPLATE_TYPE=7; break;
			case 128: TEMPLATE_TYPE=8; break;
			default: TEMPLATE_TYPE=0; break;
		}
		TOTAL_TEMPLATE += NUM_TEMPLATE_PER_TYPE[TEMPLATE_TYPE];
	}
	AVG_TEMPLATE = (float)TOTAL_TEMPLATE/TP.size();

	//save evaluate result
	ofstream myfile;
	myfile.open (pOut+"evaluation.txt");

	myfile<<"RECALL="<<RECALL_ALL<<" PREC="<<PREC_ALL<<" FPR="<<FPR_ALL<<" AVG_TEMPLATE="<<AVG_TEMPLATE<<endl;

	myfile<<"TP="<<TP_SUM<<" FP="<<FP_SUM<<" TN="<<TN_SUM<<" FN="<<FN_SUM<<" NUM_PED_SUM="<<NUM_PED_SUM<<endl;
	
	myfile.close();
}

int main(){
	pIn = "C:/TUNGDD/Code/zexp/src_ETHZ/";
	doROI_wHOG();

	return 0;
}