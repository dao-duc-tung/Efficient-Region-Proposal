#include"General_Eval.h"

General_Eval::General_Eval(){
	
}

GenROI_OF General_Eval::genROI_OF = GenROI_OF();
GenROI_Proposal General_Eval::genROI_Proposal = GenROI_Proposal();
GenROI_Ver General_Eval::genROI_Ver = GenROI_Ver();
GenROI_XCorr General_Eval::genROI_XCorr = GenROI_XCorr();
HOG General_Eval::hog = HOG();
string General_Eval::pLabel = "C:/TUNGDD/Code/zexp/src_ETHZ/lp-annot.idl";
vector<pair<Rect, float>> General_Eval::pROI = vector<pair<Rect, float>>(), General_Eval::nROI = vector<pair<Rect, float>>();
Mat General_Eval::outImgHOG = Mat(), General_Eval::outImgROI = Mat();
int General_Eval::tp=0, General_Eval::fp=0, General_Eval::tn=0, General_Eval::fn=0, General_Eval::given_roi=0, General_Eval::miss_ped=0, General_Eval::num_ped=0;

string General_Eval::getOriImgNameFromRoiPath(const string roiPath){
	size_t p1=roiPath.find_last_of("/");
	size_t p2=roiPath.find_last_of(".");
	return roiPath.substr(p1+1,16);
}

string General_Eval::getExt(const string filename){
	size_t p=filename.find_last_of(".");
	return filename.substr(p+1,3);
}
string General_Eval::rmExt(const string filename){
	size_t p=filename.find_last_of(".");
	return filename.substr(0,p);
}

void General_Eval::generateROI(string sI1, string sI2, int MODE){
	switch (MODE)
	{
		case OF_MODE:{
			genROI_OF.doMainJob(sI1,sI2);
			pROI = genROI_OF.pROI;
			nROI = genROI_OF.nROI;
			outImgROI = genROI_OF.outImg;
			break;
		}
		case PROPOSAL_MODE:{
			genROI_Proposal.doMainJob(sI1,sI2);
			pROI = genROI_Proposal.pROI;
			nROI = genROI_Proposal.nROI;
			outImgROI = genROI_Proposal.outImg;
			break;
		}
		case VER_MODE:{
			genROI_Ver.doMainJob(sI1,sI2);
			pROI = genROI_Ver.pROI;
			nROI = genROI_Ver.nROI;
			outImgROI = genROI_Ver.outImg;
			break;
		}
		case XCORR_MODE:{
			genROI_XCorr.doMainJob(sI1,sI2);
			pROI = genROI_XCorr.pROI;
			nROI = genROI_XCorr.nROI;
			outImgROI = genROI_XCorr.outImg;
			break;
		}
		default: break;
	}
}

void General_Eval::saveROIsToFile(string pOut, string pImg, vector<std::pair<Rect, float>> pROI, vector<std::pair<Rect, float>> nROI){
	ReadPed::saveROIsToFile(pOut, pImg, pROI, nROI);
}

int General_Eval::getROIswScoreFromFile(string roiPath, float threshold, vector<std::pair<Rect, float>> &pROI, vector<std::pair<Rect, float>> &nROI){
	return ReadPed::getROIswScoreFromFile(roiPath, threshold, pROI, nROI);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////TEMPORARY 15h30 22-09-2017
void General_Eval::evaluateROI_v2(string img, vector<pair<Rect, float>> pROI, vector<pair<Rect, float>> nROI){
	tp = 0; fp = 0; tn = 0; fn = 0; given_roi = 0; miss_ped=0;
	vector<Rect> pedCoor = ReadPed::getPed(img, pLabel, DEVIATE_ROI_MODE);
	num_ped = pedCoor.size();
	given_roi = pROI.size() + nROI.size();
	std::cout << "given DW=" << given_roi << std::endl;
	Mat ori = imread(img);

	//check TP & FP
	vector<bool> pedIsDetected(pedCoor.size(), false);
	for(int i=0; i<pROI.size(); i++){
		//check true roi
		bool true_roi = false;
		for(int k = 0; k < num_ped; k++){
			if (pedIsDetected[k] == true) continue;
			if(ReadPed::evaluateROI(pROI[i].first, pedCoor[k], OVERLAP_ROI)){
				true_roi = true;
				pedIsDetected[k] = true;
			}
		}
		if(true_roi){
			tp++;
			rectangle(ori, pROI[i].first, Scalar(0,255,0), 2);
		}else{
			fp++;
			rectangle(ori, pROI[i].first, Scalar(100,50,225), 1);
		}
	}

	//check TN & FN
	vector<bool> tempDetectedPed = pedIsDetected; //for drawing miss ped
	for(int i=0; i<nROI.size(); i++){
		//check true roi
		bool true_roi = false;
		for(int k = 0; k < num_ped; k++){
			if(pedIsDetected[k] == true) continue;
			if(ReadPed::evaluateROI(nROI[i].first, pedCoor[k], OVERLAP_ROI)){
				true_roi = true;
				pedIsDetected[k] = true;
			}
		}
		if(true_roi){
			fn++;
		}else{
			tn++;
		}
	}

	//draw ped
	for(int i=0; i<pedCoor.size(); i++){
		if(tempDetectedPed[i] == false){
			miss_ped++;
			rectangle(ori, pedCoor[i], Scalar(0,0,255), 1);
		}else{
			rectangle(ori, pedCoor[i], Scalar(255,0,0), 1);
		}
	}

	std::stringstream ss;
	ss << "missPed=" << miss_ped << ",FP=" << fp;
	std::string s = ss.str();
	putText(ori, s, Point(10, 40), FONT_HERSHEY_SIMPLEX, 1, Scalar(255,255,0), 1);

	outImgROI = ori;
	std::cout << "tp=" << tp << " fp=" << fp << " tn=" << tn << " fn=" << fn << std::endl;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

vector<float> General_Eval::getThresholdList(string roiPathFolder){
	vector<float> thresholdList;
	vector<pair<Rect, float>> ROI_Set;
	
	//get All ROIs in all Images in Dataset
	FileGettor fg(roiPathFolder.c_str());
	vector<string> file_list=fg.getFileList();
	for (int i=4; i<file_list.size()-1; i+=4)
	{
		if(file_list[i].compare("evaluation.txt") == 0) continue;
		if(getExt(file_list[i]).compare("txt") != 0) continue;
		cout<<"\n Get threshold List... "<<file_list[i]<<"...\n";
		string roiPath = roiPathFolder + file_list[i];

		vector<pair<Rect, float>> pROI, nROI;
		getROIswScoreFromFile(roiPath, 0, pROI, nROI);
		ROI_Set.insert(ROI_Set.end(), pROI.begin(), pROI.end());
	}

	//sort all of them by its score
	sort(ROI_Set.begin(), ROI_Set.end(), [](const std::pair<Rect, float> &left,
		const std::pair<Rect, float> &right){
			return left.second < right.second; //tang dan
	});
	
	//for Ver
	int pT=0;
	while(pT<ROI_Set.size()){
		if(ROI_Set[pT].second > 57.4){
			break;
		}else{
			pT++;
			continue;
		}
	}

	int STEP = (ROI_Set.size() - pT) / NUM_POINT_OF_CURVE;
	for(int t=pT; t<ROI_Set.size(); t+=STEP){
		thresholdList.push_back(ROI_Set[t].second);
	}

	return thresholdList;
}

void General_Eval::resetROISet(){
	pROI = vector<pair<Rect, float>>();
	nROI = vector<pair<Rect, float>>();
	genROI_OF.pROI = vector<pair<Rect, float>>();
	genROI_OF.nROI = vector<pair<Rect, float>>();
	genROI_Proposal.pROI = vector<pair<Rect, float>>();
	genROI_Proposal.nROI = vector<pair<Rect, float>>();
	genROI_Ver.pROI = vector<pair<Rect, float>>();
	genROI_Ver.nROI = vector<pair<Rect, float>>();
	genROI_XCorr.pROI = vector<pair<Rect, float>>();
	genROI_XCorr.nROI = vector<pair<Rect, float>>();
}

void General_Eval::hogForScoredROIs(string img, vector<std::pair<Rect, float>> pROI, vector<std::pair<Rect, float>> nROI){
	hog.given_roi = General_Eval::given_roi;
	hog.hogForScoredROIs(img, pROI, nROI);
	outImgHOG = hog.outImg;
	tp = hog.tp;
	fp = hog.fp;
	tn = hog.tn;
	fn = hog.fn;
}

void General_Eval::hogForScoredPROIs(string img, vector<std::pair<Rect, float>> pROI, float threshold){
	hog.hogWithoutEval(img, pROI, threshold);
	outImgHOG = hog.outImg;
}