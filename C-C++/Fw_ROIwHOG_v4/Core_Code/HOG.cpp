#include"HOG.h"

HOG::HOG(){
	pLabel = "C:/TUNGDD/Code/zexp/src_ETHZ/lp-annot.idl";
	desVecDefault = HOGDescriptor::getDefaultPeopleDetector();
	desVecFromFile = getDescriptorVectorFromFile("C:/TUNGDD/Code/zexp/descriptorvector.dat");
	HOG::scale = 1.05;
	hitThreshold = 0;
	finalThreshold = 0;
}

void HOG::hogForImage(string img){
	given_roi = 0;
	vector<Rect> detectedRect = detectHOG(img);
	vector<Rect> pedCoor = ReadPed::getPed(img, pLabel, DEVIATE_HOG_MODE);
	outImg = evaluateHOG_v3(img, detectedRect, pedCoor);
}

//for proposed method
void HOG::hogForROIs(string img, vector<Rect> rois){
	given_roi = 0;
	Mat ori = imread(img);
	vector<Rect> detectedRect;
	for(int i = 0 ; i < rois.size(); i++){
		Mat roi = ori(rois[i]).clone();
		vector<Rect> detectedRectOfROI = detectHOG(roi);

		//calculate the number of DW
		int rows=roi.rows,cols=roi.cols;
		if(rows>=128 && cols>=64){
			do{
				given_roi += (rows/8-15)*(cols/8-7);
				rows /= scale;
				cols /= scale;
			}while(rows>=128 && cols>=64);
		}

		vector<Rect> fixedDetectedRect;
		if(detectedRectOfROI.size() > 0){
			int x1,y1;
			for(int j=0; j < detectedRectOfROI.size(); j++){
				x1 = detectedRectOfROI[j].tl().x + rois[i].tl().x;
				y1 = detectedRectOfROI[j].tl().y + rois[i].tl().y;
				fixedDetectedRect.push_back(
					Rect(x1,y1,detectedRectOfROI[j].width,detectedRectOfROI[j].height));
			}
			detectedRect.insert(detectedRect.end(), fixedDetectedRect.begin(), fixedDetectedRect.end());	
		}
	}
	vector<Rect> pedCoor = ReadPed::getPed(img, pLabel, DEVIATE_HOG_MODE);
	outImg = evaluateHOG_v3(img, detectedRect, pedCoor);
}

//for edgeboxes
void HOG::hogForEBs(string img, vector<Rect> edgeBoxes){
	given_roi = 0;
	Mat ori = imread(img);
	vector<Rect> detectedRect;
	for(int i = 0 ; i < edgeBoxes.size(); i++){
		Mat roi = ori(edgeBoxes[i]).clone();
		resize(roi,roi,Size(64,128));
		vector<Rect> detectedRectOfROI = detectHOG(roi);

		//calculate the number of DW
		given_roi++;

		vector<Rect> fixedDetectedRect;
		if(detectedRectOfROI.size() > 0){
			int x1,y1;
			for(int j=0; j < detectedRectOfROI.size(); j++){
				x1 = detectedRectOfROI[j].tl().x*64/edgeBoxes[i].width + edgeBoxes[i].tl().x;
				y1 = detectedRectOfROI[j].tl().y*128/edgeBoxes[i].height + edgeBoxes[i].tl().y;
				fixedDetectedRect.push_back(
					Rect(x1,y1,
					detectedRectOfROI[j].width*64/edgeBoxes[i].width,
					detectedRectOfROI[j].height*128/edgeBoxes[i].height));
			}
			detectedRect.insert(detectedRect.end(), fixedDetectedRect.begin(), fixedDetectedRect.end());	
		}

	}
	vector<Rect> pedCoor = ReadPed::getPed(img, pLabel, DEVIATE_HOG_MODE);
	outImg = evaluateHOG_v3(img, detectedRect, pedCoor);
}

void HOG::hogWithoutEval(string img, vector<std::pair<Rect, float>> pROI, float threshold){
	Mat ori = imread(img);
	vector<Rect> detectedRect;

	for(int i = 0 ; i < pROI.size(); i++){
		if(pROI[i].second <= threshold) continue;
		Mat roi = ori(pROI[i].first).clone();
		resize(roi, roi, Size(64,128));
		vector<Rect> detectedRectOfROI = detectHOG(roi);
		if(detectedRectOfROI.size() > 0){
			detectedRect.push_back(pROI[i].first);
		}
	}

	outImg = displayRectInImg(detectedRect, ori);
}
void HOG::hogForScoredROIs(string img, vector<std::pair<Rect, float>> pROI, vector<std::pair<Rect, float>> nROI){
	Mat ori = imread(img);
	vector<Rect> detectedRect;

	for(int i = 0 ; i < pROI.size(); i++){
		Mat roi = ori(pROI[i].first).clone();
		resize(roi, roi, Size(64,128));
		vector<Rect> detectedRectOfROI = detectHOG(roi);
		if(detectedRectOfROI.size() > 0){
			detectedRect.push_back(pROI[i].first);
		}
	}
	vector<Rect> pedCoor = ReadPed::getPed(img, pLabel, DEVIATE_HOG_MODE);
	outImg = evaluateHOG_v3(img, detectedRect, pedCoor);
}
vector<Rect> HOG::detectHOG(Mat ori){
	Size win_stride(8,8);
	Size win_size(64,128);
	Size block_size(16,16);
	Size block_stride(8,8);
	Size cell_size(8,8);
	HOGDescriptor hogd(win_size, block_size, block_stride, cell_size, 9);
	vector<float> svm = getDescriptorVector(DESVEC_FROMFILE);
	hogd.setSVMDetector(svm);

	vector<Point> detectedRect;
	hitThreshold = 1.0625;
	hogd.detect(ori, detectedRect, hitThreshold);
	
	vector<Rect> temp;
	if(detectedRect.size() > 0)
		temp.push_back(Rect(Point(0,0), Point(64,128)));
	return temp;
}

vector<Rect> HOG::detectHOG(string img){
	Mat ori = imread(img);
	vector<Rect> detectedRect;
	detectedRect = detectHOG(ori);
	return detectedRect;
}

vector<Rect> HOG::detectMultiScaleHOG(string img){
	Mat ori = imread(img);
	
	Size win_stride(8,8);
	Size win_size(64,128);
	Size block_size(16,16);
	Size block_stride(8,8);
	Size cell_size(8,8);
	HOGDescriptor hogd(win_size, block_size, block_stride, cell_size, 9);
	vector<float> svm = getDescriptorVector(DESVEC_FROMFILE);
	hogd.setSVMDetector(svm);

	vector<Rect> detectedRect;
	hitThreshold = 1.0625;
	hogd.detectMultiScale(ori, detectedRect, hitThreshold, win_stride, Size(0,0), scale, finalThreshold, true);

	return detectedRect;
}

Mat HOG::displayRectInImg(vector<Rect> rect, Mat img){
	for(int i = 0; i<rect.size(); i++){
		rectangle(img, rect[i], Scalar(0,255,0), 1);
	}
	return img;
}

Mat HOG::evaluateHOG_v3(string img, vector<Rect> detectedRect, vector<Rect> pedCoor){
	fn=0; num_ped=0; num_true_roi=0; num_roi=0; tp=0; fp=0; tn=0;
	num_ped = pedCoor.size();
	std::cout << "given DW=" << given_roi << std::endl;
	vector<std::pair<Rect, bool>> trueROI;
	Mat ori = imread(img);

	vector<std::pair<float,int>> pedIsDetected(pedCoor.size(), std::pair<float,int>(-1,-1));
	//choose the ped for each roi
	for(int i=0; i<detectedRect.size(); i++){
		float max_o = 0;
		int idx_ped = -1;
		for(int k=0; k<num_ped; k++){
			float temp_o = ReadPed::evaluateROI(detectedRect[i], pedCoor[k]);
			if(temp_o > max_o && temp_o > OVERLAP_HOG){
				max_o = temp_o;
				idx_ped = k;
			}
		}
		
		if(idx_ped != -1 && max_o > pedIsDetected[idx_ped].first){
			pedIsDetected[idx_ped].first = max_o;
			pedIsDetected[idx_ped].second = i;
		}
	}
	
	//draw detected Ped and FN (miss_ped)
	vector<int> idxTP;	//save index of TP
	for(int k=0; k<num_ped; k++){
		if(pedIsDetected[k].second > -1){
			rectangle(ori, pedCoor[k], Scalar(255,0,0), 1);
			//get index of tp
			idxTP.push_back(pedIsDetected[k].second);
		}else{
			fn++;
			rectangle(ori, pedCoor[k], Scalar(0,0,255), 1);
		}
	}

	//draw tp & fp ROI
	for(int i=0; i<detectedRect.size(); i++){
		if(find(idxTP.begin(), idxTP.end(), i) == idxTP.end()){
			fp++;
			rectangle(ori, detectedRect[i], Scalar(50,100,225), 1);
		}else{//draw tp again
			tp++;
			rectangle(ori, detectedRect[i], Scalar(0,255,0), 2);
		}
	}

	//check TN & FN
	tn = given_roi - fn - tp - fp;

	std::stringstream ss;
	ss << "missPed=" << fn << "/" << num_ped << ", FP=" << fp << "/" << detectedRect.size();
	std::string s = ss.str();
	putText(ori, s, Point(10, 40), FONT_HERSHEY_SIMPLEX, 1, Scalar(255,255,0), 1);

	outImg = ori;
	std::cout << "tp=" << tp << " fp=" << fp << " tn=" << tn << " fn=" << fn << std::endl;

	return ori;
}

vector<float> HOG::getDescriptorVectorFromFile(const string& vectorFile){
	std::ifstream file(vectorFile.c_str(), std::ifstream::in);
	string str;
	std::getline(file, str, '\0');

	vector<float> desVec;
	string::size_type pos = 0;
	string::size_type prev = 0;
	const string delimeter = " ";
	while((pos = str.find(delimeter, prev)) != string::npos){
		desVec.push_back(std::stof(str.substr(prev, pos-prev).c_str(), 0));
		prev = pos + delimeter.size();
	}

	return desVec;
}

vector<float> HOG::getDescriptorVector(int type){
	if(type == DESVEC_DEFAULT){
		return desVecDefault;
	}else if(type == DESVEC_FROMFILE){
		return desVecFromFile;
	}else{
		return vector<float>();
	}
}