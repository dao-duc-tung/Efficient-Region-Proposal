#include"GenROI_XCorr.h"

GenROI_XCorr::GenROI_XCorr(){
	pLabel = "C:/TUNGDD/Code/zexp/src_ETHZ/lp-annot.idl";
}

int GenROI_XCorr::THRES_SOBEL = 90;

int GenROI_XCorr::THRES_GRAD = 20;

int GenROI_XCorr::MIN_WIDTH = 16, GenROI_XCorr::MIN_HEIGHT = 32;
int GenROI_XCorr::MAX_WIDTH = 120, GenROI_XCorr::MAX_HEIGHT = 240;

int GenROI_XCorr::STEP_WIDHT = 8, GenROI_XCorr::STEP_HEIGHT = 16;
int GenROI_XCorr::MIN_PIXEL_ROI = 15, GenROI_XCorr::MIN_PIXEL_LEG = 10;
int GenROI_XCorr::ROW_STEP_WINDOW = 8, GenROI_XCorr::COL_STEP_WINDOW = 8;
float GenROI_XCorr::THRES_NMS_ROI = 0.7;
int GenROI_XCorr::NUM_ROI = 0;

vector<std::pair<Rect, float>> GenROI_XCorr::doMainJob(string sI1, string sI2){
	Mat I1 = imread(sI1, CV_LOAD_IMAGE_GRAYSCALE);
	Mat I2 = imread(sI2, CV_LOAD_IMAGE_GRAYSCALE);
	Point transVector = getTransVector(I1, I2);
	Mat Id = getMovingArea(I1,I2,transVector);
	movingArea = Id;
	generateROI(I2, Id, pROI, nROI);
	return pROI;
}

Point GenROI_XCorr::getTransVector(Mat I1, Mat I2){
	Mat edge1, edge2;
	edgeSobel(I1, edge1, Mat(), Mat(), THRES_SOBEL);
	edgeSobel(I2, edge2, Mat(), Mat(), THRES_SOBEL);
	
	dilate(edge1, edge1, getStructuringElement(MORPH_RECT, Size(3,3)));
	Point translation_vector = xcorr(edge1, edge2);

	return translation_vector;
}

Mat GenROI_XCorr::getMovingArea(Mat I1, Mat I2, Point transVector){
	Mat MovingArea, I1VerGrad, I2VerGrad;
	gradient(I1, I1VerGrad, Mat(), Mat(), -1);
	gradient(I2, I2VerGrad, Mat(), Mat(), -1);
	Mat It = translateImage(I1VerGrad, transVector);
	MovingArea = cv::abs(I2VerGrad - It);
	threshold(MovingArea, MovingArea, THRES_GRAD, 255, THRESH_BINARY);
	erode(MovingArea, MovingArea, 2);
	dilate(MovingArea, MovingArea, 3);

	return MovingArea;
}
void GenROI_XCorr::generateROI(Mat I2, Mat MovingArea, vector<std::pair<Rect, float>>& pROI, vector<std::pair<Rect, float>>& nROI){
	int rows=I2.rows,cols=I2.cols;
	Mat I2_Ver_Grad,I2_Hor_Grad,I2_Mag_Grad;
	gradient(I2, I2_Mag_Grad, I2_Ver_Grad, I2_Hor_Grad, -1);
	int vanishing_line = getVanishingLine(pLabel);
	//generate ROI with corresponding score
	vector<std::pair<Rect, float>> ROI;
	int WIDHT_ROI = GenROI_XCorr::MIN_WIDTH, HEIGHT_ROI = GenROI_XCorr::MIN_HEIGHT;
	while(WIDHT_ROI<=MAX_WIDTH && HEIGHT_ROI<=MAX_HEIGHT){
		int x1_slide = 0, x2_slide = cols-1;
		int y1_slide = vanishing_line-HEIGHT_ROI/2-1;
		int y2_silde = vanishing_line+HEIGHT_ROI-1;
		for(int r=y1_slide;r<=y2_silde-HEIGHT_ROI; r+=ROW_STEP_WINDOW){
			for(int c=x1_slide;c<=x2_slide-WIDHT_ROI; c+=COL_STEP_WINDOW){
				//get the sliding win which has moving edges
				int y1 = r, x1 = c;
				int y2 = r + HEIGHT_ROI, x2 = c + WIDHT_ROI;

				//leg region - dynamic feature
				Mat MovingWindow = MovingArea(Range(y1, y2), Range(x1, x2));
				Mat leg_win = MovingWindow(Range(4 * HEIGHT_ROI / 8, 7 * HEIGHT_ROI / 8), Range(WIDHT_ROI / 4, 3 * WIDHT_ROI / 4));
				int LEG_PIXEL = countNonZero(leg_win);

				//vertical gradient - static feature
				Mat ver_grad_win = I2_Ver_Grad(Rect(Point(x1, y1), Point(x2, y2)));
				int VER = countNonZero(ver_grad_win);

				//probability function
				float PROB = sqrt(pow(LEG_PIXEL, 2) + VER) / (HEIGHT_ROI * WIDHT_ROI);

				//threshold
				if (PROB < 0.01) {
					nROI.push_back(std::pair<Rect, float>(Rect(Point(x1, y1), Point(x2, y2)), PROB));
				}
				else {
					ROI.push_back(std::pair<Rect, float>(Rect(Point(x1, y1), Point(x2, y2)), PROB));
				}
			}
		}
		WIDHT_ROI+=STEP_WIDHT;
		HEIGHT_ROI+=STEP_HEIGHT;
	}

	vector<std::pair<Rect, float>> filteredROI, removedROI;
	//vector<Rect> pROI, nROI;
	nms(ROI, GenROI_XCorr::THRES_NMS_ROI, filteredROI, removedROI);
	nROI.insert(nROI.end(), removedROI.begin(), removedROI.end());

	//get the top ROIs
	if(NUM_ROI == 0){
		pROI.insert(pROI.end(), filteredROI.begin(), filteredROI.end());
	}else{
		for(int i=0; i < filteredROI.size(); i++){
			if(i <= NUM_ROI){
				pROI.push_back(filteredROI[i]);
			}else{
				nROI.push_back(filteredROI[i]);
			}
		}
	}
}
void GenROI_XCorr::nms(vector<std::pair<Rect, float>> ROIs, float overlapThresh, vector<std::pair<Rect, float>>& filteredROI, vector<std::pair<Rect, float>>& removedROI){
	//Using Fast Non-Maximum Suppressing
	vector<std::pair<Rect, float>> tempROI(ROIs);
	int num_rect = tempROI.size();
	if(num_rect == 0) return;
	vector<float> x1, y1, x2, y2, area;

	//sort rectDetected descending by the scores HOG of the rect
	sort(tempROI.begin(), tempROI.end(), [](const std::pair<Rect, float> &left,
		const std::pair<Rect, float> &right){
			return left.second < right.second;
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

vector<std::pair<Rect, float>> GenROI_XCorr::evaluateROI_v2(string img, vector<std::pair<Rect, float>> pROI, vector<std::pair<Rect, float>> nROI, vector<Rect> pedCoor){
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

void GenROI_XCorr::displayRect(Mat I2, vector<Rect> ROIs){
	for(int i = 0; i < ROIs.size(); i++){
		Rect r = ROIs[i];
		rectangle(I2, r.tl(), r.br(), Scalar(0, 255, 0), 1);
	}
	GenROI_XCorr::outImg = I2;
}
Mat GenROI_XCorr::translateImage(Mat I1, Point transVector){
	int rows = I1.rows, cols = I1.cols;
	Mat out(I1.rows,I1.cols,I1.type(),Scalar::all(0));
	uchar* pOut = (uchar*)(out.data);
	uchar* pI1 = (uchar*)(I1.data);
	for(int a = 0; a < rows; a++){
		for(int b = 0; b < cols; b++){
			int x_ = b+transVector.x;
			int y_ = a+transVector.y;
			size_t idx = cols*a + b;
			if(x_>=0 && y_>=0 && x_<cols && y_<rows){
				pOut[idx] = pI1[cols*y_ + x_];
			}
		}
	}
	return out;
}

vector<Point> GenROI_XCorr::initCorners(Mat I1, int dis_fr_bound, int search_size){
	int rows=I1.rows,cols=I1.cols;
	int num_sub_win = 4;
	int sigma=1,radius=2,score=(2*radius+1);
	double thres=0.4;
	//derivative in x and y direction
	Mat Ix,Iy;
	gradient(I1, Mat(), Ix, Iy, -1);
	//implementing the gaussian filter
	int dim=max(1,6*sigma);
	Mat g = getGaussianKernel(dim, sigma, CV_64F);
	Mat Ix2(rows,cols,CV_64F);
	Mat Iy2(rows,cols,CV_64F);
	Mat Ixy(rows,cols,CV_64F);
	filter2D(Ix.mul(Ix), Ix2, CV_64F, g);
	filter2D(Iy.mul(Iy), Iy2, CV_64F, g);
	filter2D(Ix.mul(Iy), Ixy, CV_64F, g);
	//Harris measure
	Mat R(rows,cols,CV_64F);
	R = (Ix2.mul(Iy2) - Ixy.mul(Ixy)) - 0.04*((Ix2+Iy2).mul(Ix2+Iy2));
	double minr, maxr;
	minMaxLoc(R, &minr, &maxr);
	R = (R - minr)/(maxr-minr);
	//thres and get harris point
	int x1 = dis_fr_bound+search_size/2, x5 = cols-x1;
	int x3 = cols/2,x2 = (x1+x3)/2;
	int x4 = (x3+x5)/2,y1 = x1, y2 = rows/3;

	vector<Point> corners(num_sub_win, Point(0,0));
	vector<double> max_R(num_sub_win, 0);
	for(int r = y1; r <= y2; r++){
		for(int c = x1; c <= x5; c++){
			double tempR = R.at<double>(r,c);
			if(tempR > thres){
				int area = -1;
				if(c<x2){
					area = 0;
				}else if(c>=x2 && c<x3){
					area = 1;
				}else if(c>=x3 && c<x4){
					area = 2;
				}else if(c>=x4){
					area = 3;
				}
				if(area>-1 && max_R[area] < tempR){
					max_R[area] = tempR;
					corners[area].x = c;
					corners[area].y = r;
				}
			}
		}
	}
	vector<Point> sub_win;
	for(int i = 0; i < num_sub_win; i++){
		if (corners[i].x>=x1){
			sub_win.push_back(corners[i]);
		}
	}
	return sub_win;
}
Mat GenROI_XCorr::getGrayCode(Mat I){
	return I;
}

int GenROI_XCorr::getVanishingLine(string pLabel){
	string label_TUD_Crossing = "C:/TUNGDD/Code/zexp/src_TUD_Crossing/tud-crossing-sequence.idl";
	string label_ETHZ = "C:/TUNGDD/Code/zexp/src_ETHZ/lp-annot.idl";

	if(pLabel.compare(label_ETHZ)==0){
		return 185;
	}else if(pLabel.compare(label_TUD_Crossing)==0){
		return 201;
	}
}

void GenROI_XCorr::gradient(Mat input, Mat& magnitude, Mat& vGrad, Mat& hGrad, int thres){
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

void GenROI_XCorr::edgeSobel(Mat input, Mat& edge, Mat& vEdge, Mat& hEdge, int thres){
	Mat h,v,m,a;
	Sobel(input, h, CV_32F, 0, 1, 3);
	Sobel(input, v, CV_32F, 1, 0, 3);
	convertScaleAbs(h, h);
	convertScaleAbs(v, v);
	addWeighted(h, 1, v, 1, 0, m);
	if(thres != -1){
		threshold(h, h, thres, 255, THRESH_BINARY);
		threshold(v, v, thres, 255, THRESH_BINARY);
		threshold(m, m, thres, 255, THRESH_BINARY);
	}
	edge = m;
	vEdge = v;
	hEdge = h;
}

Point GenROI_XCorr::xcorr(Mat img1, Mat img2){
	Mat C;
	Point maxLoc;
	Point center_C(img1.cols-1, img1.rows-1);
	Mat temp(3*img1.rows-2, 3*img1.cols-2, img1.type(), Scalar::all(0));
	img1.copyTo(temp(Rect(img1.cols-1, img1.rows-1, img1.cols, img1.rows)));
	matchTemplate(temp, img2, C, CV_TM_CCORR);
	minMaxLoc(C,0,0,0,&maxLoc);
	Point translation_vector = maxLoc - center_C;
	return translation_vector;
}