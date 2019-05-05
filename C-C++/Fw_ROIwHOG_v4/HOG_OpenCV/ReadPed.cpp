#include"ReadPed.h"

ReadPed::ReadPed(){

}

int ReadPed::DEVIATE = 0;
string ReadPed::label_ETHZ = "E:/DAO DUC TUNG/TestBMS/src_ETHZ/lp-annot.idl";

bool ReadPed::evaluateROI(Rect roi, Rect ped, float IoU){
	int xx1 = MAX(roi.tl().x, ped.tl().x), yy1 = MAX(roi.tl().y, ped.tl().y);
	int xx2 = MIN(roi.br().x, ped.br().x), yy2 = MIN(roi.br().y, ped.br().y);
	int w = MAX(xx2-xx1+1, 0), h = MAX(yy2-yy1+1, 0);
	float overlap = (float)(w*h)/(roi.area()+ped.area()-(w*h));
	if (overlap > IoU) return true;
	else return false;
}

bool ReadPed::evaluateWhollyEnclosedPed(Rect roi, Rect ped){
	int x1 = roi.tl().x, y1 = roi.tl().y;
	int x2 = roi.br().x, y2 = roi.br().y;
	int x1ped = ped.tl().x, y1ped = ped.tl().y;
	int x2ped = ped.br().x, y2ped = ped.br().y;
	if(x1<=x1ped && y1<=y1ped && x2>=x2ped && y2>=y2ped) return true;
	else return false;
}

float ReadPed::evaluateROI(Rect roi, Rect ped){
	int xx1 = MAX(roi.tl().x, ped.tl().x), yy1 = MAX(roi.tl().y, ped.tl().y);
	int xx2 = MIN(roi.br().x, ped.br().x), yy2 = MIN(roi.br().y, ped.br().y);
	int w = MAX(xx2-xx1+1, 0), h = MAX(yy2-yy1+1, 0);
	float overlap = (float)(w*h)/(roi.area()+ped.area()-(w*h));
	return overlap;
}

vector<Rect> ReadPed::getROIsFromFile(string roiPath){
	vector<Rect> rois;
	std::ifstream file(roiPath);
	std::string str;
	while (std::getline(file, str))
	{
		std::stringstream ss(str); // Insert the string into a stream
		std::string buf; // Have a buffer string
		vector<std::string> tokens; // Create vector to hold our words
		while (ss >> buf)
			tokens.push_back(buf);

		rois.push_back(
			Rect(Point(std::stoi(tokens[0]),std::stoi(tokens[1])),
			Point(std::stoi(tokens[2]),std::stoi(tokens[3]))));
	}

	return rois;
}

vector<Rect> ReadPed::getPed(string img, string pLabel, int deviate){
	ReadPed::DEVIATE = deviate;
	if(pLabel.compare(ReadPed::label_ETHZ) == 0){
		return getPedFromETHZ(img);
	}else{
		return vector<Rect>();
	}
}

vector<Rect> ReadPed::getPedFromETHZ(string img){
	vector<Rect> PedCoor;
	size_t p = img.find_last_of(".");
	string s = img.substr(p-6,img.size()-p);
	int order = (stoi(s)%4900)/4+1;

	string input_file = "E:/DAO DUC TUNG/TestBMS/src_ETHZ/lp-annot.idl";
	std::ifstream file(input_file);
	std::string str;
	vector<string> data;
	int n = 0;
	while(std::getline(file, str) && n < order){
		n++;
		if(n!=order) continue;
		std::stringstream ss(str); // Insert the string into a stream
		std::string s1; // Have a buffer string
		while (ss >> s1)
			data.push_back(s1);

		vector<string> tokens; // Create vector to hold our words

		for(int i = 0; i < data.size(); i++){
			int p = data[i].find_first_of("(");
			if(p>=0) data[i] = data[i].substr(p+1, data[i].size());
			p = data[i].find_last_of(",");
			if(p>=0) data[i] = data[i].substr(0, p);
			p = data[i].find_last_of(")");
			if(p>=0) data[i] = data[i].substr(0, p);
			tokens.push_back(data[i]);
		}
		tokens.erase(tokens.begin());

		for(int i = 0; i < tokens.size(); i+=4){
			int x1 = stoi(tokens[i]), y1 = stoi(tokens[i+1]);
			int x2 = stoi(tokens[i+2]), y2 = stoi(tokens[i+3]);
			x1 = max(x1, 0); y1 = max(y1, 0); x2 = max(x2, 0); y2 = max(y2, 0);
			x1 = min(x1, COLS_READ_PED-1); y1 = min(y1, ROWS_READ_PED-1);
			x2 = min(x2, COLS_READ_PED-1); y2 = min(y2, ROWS_READ_PED-1);
			PedCoor.push_back(Rect(Point(x1, y1),Point(x2, y2)));
		}
	}

	return deviatePed(PedCoor, DEVIATE);
}

vector<Rect> ReadPed::deviatePed(vector<Rect> PedCoor, int deviate){
	//if(deviate <= 0) return PedCoor;
	if(PED_RATIO == 0) return PedCoor;
	int COLS = 640;
	vector<Rect> temp_Ped;
	for(int i = 0; i < PedCoor.size(); i++){
		int x1 = PedCoor[i].tl().x, y1 = PedCoor[i].tl().y;
		int x2 = PedCoor[i].br().x, y2 = PedCoor[i].br().y;
		if(x1<NEAR_BOUNDARY||x2>(COLS-NEAR_BOUNDARY)) continue;
		int w = x2-x1, h = y2-y1;
		if (w*h < THRESH_PEDCOOR) continue;
		int hD = h*deviate/100/2;
		y1=y1+hD; y2=y2-hD;
		
		int newH = y2-y1;
		int newW = newH*PED_RATIO;
		int center_x = (x1+x2)/2;
		x1 = center_x-newW/2;
		x2 = center_x+newW/2;

		temp_Ped.push_back(Rect(Point(x1,y1),Point(x2,y2)));
	}
	return temp_Ped;
}