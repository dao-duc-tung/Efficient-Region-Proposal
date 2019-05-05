#include"GenROI_Ver.h"

GenROI_Ver::GenROI_Ver(){
	pLabel = "C:/TUNGDD/Code/zexp/src_ETHZ/lp-annot.idl";
}

int GenROI_Ver::THRES_GRAD = 20;

int GenROI_Ver::MIN_WIDTH = 16, GenROI_Ver::MIN_HEIGHT = 32;
int GenROI_Ver::MAX_WIDTH = 120, GenROI_Ver::MAX_HEIGHT = 240;

int GenROI_Ver::STEP_WIDHT = 8, GenROI_Ver::STEP_HEIGHT = 16;
int GenROI_Ver::MIN_PIXEL_ROI = 15, GenROI_Ver::MIN_PIXEL_LEG = 10;
int GenROI_Ver::ROW_STEP_WINDOW = 4, GenROI_Ver::COL_STEP_WINDOW = 4;
float GenROI_Ver::THRES_NMS_ROI = 0.7;
int GenROI_Ver::NUM_ROI = 0;

vector<std::pair<Rect, float>> GenROI_Ver::doMainJob(string sI1, string sI2){
	return doMainJob(sI2);
}

vector<std::pair<Rect, float>> GenROI_Ver::doMainJob(string sI){
	Mat I = imread(sI, CV_LOAD_IMAGE_GRAYSCALE);
	generateROI(I, pROI, nROI);
	return pROI;
}

void GenROI_Ver::generateROI(Mat I, vector<std::pair<Rect, float>>& pROI, vector<std::pair<Rect, float>>& nROI){
	int rows=I.rows,cols=I.cols;
	Mat I_Ver_Grad;
	gradient(I, Mat(), I_Ver_Grad, Mat(), THRES_GRAD);
	int vanishing_line = getVanishingLine(pLabel);
	//generate ROI with corresponding score
	vector<std::pair<Rect, float>> ROI;
	int WIDHT_ROI = GenROI_Ver::MIN_WIDTH, HEIGHT_ROI = GenROI_Ver::MIN_HEIGHT;
	while(WIDHT_ROI<=MAX_WIDTH && HEIGHT_ROI<=MAX_HEIGHT){
		int x1_slide = 0, x2_slide = cols-1;
		int y1_slide = vanishing_line-HEIGHT_ROI/2-1;
		int y2_silde = vanishing_line+HEIGHT_ROI-1;
		for(int r=y1_slide;r<=y2_silde-HEIGHT_ROI; r+=ROW_STEP_WINDOW){
			for(int c=x1_slide;c<=x2_slide-WIDHT_ROI; c+=COL_STEP_WINDOW){
				//get the sliding win which has moving edges
				int y1=r, x1=c;
				int y2=r+HEIGHT_ROI, x2=c+WIDHT_ROI;

				Mat ver_grad_win = I_Ver_Grad(Rect(Point(x1,y1),Point(x2,y2)));
				float VER_Nmz = (float)sum(ver_grad_win)[0]/(ver_grad_win.rows*ver_grad_win.cols);

				float PROB = VER_Nmz;

				ROI.push_back(std::pair<Rect, float>(Rect(Point(x1, y1), Point(x2, y2)), PROB));
			}
		}
		WIDHT_ROI+=STEP_WIDHT;
		HEIGHT_ROI+=STEP_HEIGHT;
	}

	pROI.insert(pROI.end(), ROI.begin(), ROI.end());
	sort(pROI.begin(), pROI.end(), [](const std::pair<Rect, float> &left,
		const std::pair<Rect, float> &right){
			return left.second > right.second;//giam dan
	});
}
void GenROI_Ver::nms(vector<std::pair<Rect, float>> ROIs, float overlapThresh, vector<std::pair<Rect, float>>& filteredROI, vector<std::pair<Rect, float>>& removedROI){
	//Using Fast Non-Maximum Suppressing
	vector<std::pair<Rect, float>> tempROI(ROIs);
	int num_rect = tempROI.size();
	if(num_rect == 0) return;
	vector<float> x1, y1, x2, y2, area;

	//sort rectDetected descending by the scores HOG of the rect
	sort(tempROI.begin(), tempROI.end(), [](const std::pair<Rect, float> &left,
		const std::pair<Rect, float> &right){
			return left.second < right.second;//tang dan
	});
	//grab the coordinates of the rects
	//compute the area of the rects
	//init the list of index of sorted rect
	vector<int> idxs;
	for(int i = 0; i < num_rect; i++){
		Rect p = tempROI[i].first;
		x1.push_back(p.tl().x);
		y1.push_back(p.tl().y);
		x2.push_back(p.br().x);
		y2.push_back(p.br().y);
		area.push_back(p.width*p.height);
		idxs.push_back(i);
	}
	//initial the list of picked indexes
	vector<int> pick;
	vector<int> unpick;
	while(idxs.size() > 0){
		vector<float> xx1, yy1, xx2, yy2, overlap, w, h;
		//grab the last index in the rect list
		//add the index value to the list of picked indexes
		int last = idxs.size() - 1;
		int i = idxs[last];
		pick.push_back(i);
		//find the largest coordinates for the start of the rect
		//and the smallest coordinates for the end of the rect
		//compute the width and height of the rect
		//compute the ratio of overlap
		for(int j = 0; j < last; j++){
			xx1.push_back(MAX(x1[i], x1[idxs[j]]));
			yy1.push_back(MAX(y1[i], y1[idxs[j]]));
			xx2.push_back(MIN(x2[i], x2[idxs[j]]));
			yy2.push_back(MIN(y2[i], y2[idxs[j]]));
			w.push_back(MAX(xx2[j] - xx1[j] + 1, 0));
			h.push_back(MAX(yy2[j] - yy1[j] + 1, 0));
			overlap.push_back((w[j]*h[j])/(area[i]+area[idxs[j]]-(w[j]*h[j])));
		}
		//delete the last index
		idxs.pop_back();
		//delete all indexes from the index list that have
		int k = 0, temp_idx = 0;
		for(int m = 0; m < overlap.size(); m++){
			if(overlap[m] >= overlapThresh){
				temp_idx = m - k;
				unpick.push_back(idxs[temp_idx]);
				idxs.erase(idxs.begin()+temp_idx);
				k++;
			}
		}
	}

	//collect picked rect
	for(int i = 0; i < pick.size(); i++){
		filteredROI.push_back(tempROI[pick[i]]);
	}

	//collect unpicked rect
	for(int i=0; i<unpick.size(); i++){
		removedROI.push_back(tempROI[unpick[i]]);
	}
}

vector<std::pair<Rect, float>> GenROI_Ver::evaluateROI_v2(string img, vector<std::pair<Rect, float>> pROI, vector<std::pair<Rect, float>> nROI, vector<Rect> pedCoor){
	tp = 0; fp = 0; tn = 0; fn = 0; given_roi = 0; miss_ped=0;
	num_ped = pedCoor.size();
	given_roi = pROI.size() + nROI.size();
	std::cout << "given_roi=" << given_roi << std::endl;
	Mat ori = imread(img);

	//check TP & FP
	vector<bool> pedIsDetected(pedCoor.size(), false);
	for(int i=0; i<pROI.size(); i++){
		//check true roi
		bool true_roi = false;
		for(int k = 0; k < num_ped; k++){
			if (pedIsDetected[k] == true) continue;
			if(ReadPed::evaluateROI(pROI[i].first, pedCoor[k], OVERLAP_ROI)
				|| ReadPed::evaluateWhollyEnclosedPed(pROI[i].first, pedCoor[k])){
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
			if(ReadPed::evaluateROI(nROI[i].first, pedCoor[k], OVERLAP_ROI)
				|| ReadPed::evaluateWhollyEnclosedPed(nROI[i].first, pedCoor[k])){
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

	outImg = ori;
	std::cout << "tp=" << tp << " fp=" << fp << " tn=" << tn << " fn=" << fn << std::endl;

	return pROI;
}

void GenROI_Ver::displayRect(Mat I2, vector<Rect> ROIs){
	for(int i = 0; i < ROIs.size(); i++){
		Rect r = ROIs[i];
		rectangle(I2, r.tl(), r.br(), Scalar(0, 255, 0), 1);
	}
	GenROI_Ver::outImg = I2;
}

int GenROI_Ver::getVanishingLine(string pLabel){
	string label_TUD_Crossing = "C:/TUNGDD/Code/zexp/src_TUD_Crossing/tud-crossing-sequence.idl";
	string label_ETHZ = "C:/TUNGDD/Code/zexp/src_ETHZ/lp-annot.idl";

	if(pLabel.compare(label_ETHZ)==0){
		return 185;
	}else if(pLabel.compare(label_TUD_Crossing)==0){
		return 201;
	}
}

void GenROI_Ver::gradient(Mat input, Mat& magnitude, Mat& vGrad, Mat& hGrad, int thres){
	Mat h,v,m,a;
	Sobel(input, h, CV_32F, 0, 1, 1); //[-1; 0; 1]
	Sobel(input, v, CV_32F, 1, 0, 1); //[-1 0 1]
	convertScaleAbs(h, h);
	convertScaleAbs(v, v);
	addWeighted(h, 1, v, 1, 0, m);
	if(thres != -1){
		threshold(h, h, thres, 255, THRESH_BINARY);
		threshold(v, v, thres, 255, THRESH_BINARY);
		threshold(m, m, thres, 255, THRESH_BINARY);
	}
	magnitude = m;
	vGrad = v;
	hGrad = h;
}