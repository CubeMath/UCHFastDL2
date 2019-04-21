
array<Vector> play_area_instinct_9 = {
  Vector(-1706.0, -2724.0, 77.0),
  Vector(-1726.0, -2727.0, 80.0),
  Vector(-1726.0, -2815.0, 102.0),
  Vector(-1805.0, -3287.0, 120.0),
  Vector(-1824.0, -3328.0, 120.0),
  Vector(-1824.0, -3568.0, 120.0),
  Vector(-1985.0, -3624.0, -4.0),
  Vector(-2359.0, -3428.0, 44.0),
  Vector(-2714.0, -3354.0, 95.0),
  Vector(-2586.0, -3194.0, 363.0),
  Vector(-2513.0, -2716.0, 374.0),
  Vector(-2558.0, -2485.0, 236.0),
  Vector(-1984.0, -2380.0, 236.0),
  Vector(-1984.0, -2190.0, 216.0),
  Vector(-1948.0, -2178.0, 218.0),
  Vector(-1873.0, -2111.0, 236.0),
  Vector(-1856.0, -1996.0, 286.0),
  Vector(-1984.0, -1717.0, 256.0),
  Vector(-2227.0, -1779.0, 336.0),
  Vector(-2262.0, -1626.0, 517.0),
  Vector(-2267.0, -1539.0, 468.0),
  Vector(-2250.0, -1096.0, 474.0),
  Vector(-2263.0, -1058.0, 482.0),
  Vector(-2448.0, -872.0, 384.0),
  Vector(-2448.0, -537.0, 295.0),
  Vector(-2183.0, -544.0, 278.0),
  Vector(-2021.0, -415.0, 416.0),
  Vector(-1634.0, 548.0, 416.0),
  Vector(-1670.0, 639.0, 309.0),
  Vector(-1357.0, 1113.0, 314.0),
  Vector(-837.0, 1134.0, 511.0),
  Vector(-551.0, 1278.0, 461.0),
  Vector(-205.0, 1690.0, 207.0),
  Vector(-14.0, 1726.0, 415.0),
  Vector(362.0, 1900.0, 291.0),
  Vector(404.0, 1957.0, 268.0),
  Vector(404.0, 2330.0, 268.0),
  Vector(-435.0, 3024.0, 528.0),
  Vector(1536.0, 3024.0, 528.0),
  Vector(1536.0, 3024.0, 848.0),
  Vector(1791.0, 2805.0, 948.0),
  Vector(2117.0, 2568.0, 496.0),
  Vector(2010.0, 1845.0, 496.0),
  Vector(2178.0, 1688.0, 496.0),
  Vector(2616.0, 1613.0, 496.0),
  Vector(2984.0, 1016.0, 360.0),
  Vector(2882.0, 585.0, 360.0),
  Vector(2421.0, 504.0, 463.0),
  Vector(2314.0, -219.0, 463.0),
  Vector(2482.0, -376.0, 463.0),
  Vector(2610.0, -455.0, 377.0),
  Vector(2832.0, -912.0, 377.0),
  Vector(2672.0, -1384.0, 629.0),
  Vector(2253.0, -1268.0, 772.0),
  Vector(2034.0, -1215.0, 774.0),
  Vector(1555.0, -1267.0, 787.0),
  Vector(1267.0, -1380.0, 640.0),
  Vector(1250.0, -1254.0, 640.0),
  Vector(966.0, -894.0, 640.0),
  Vector(862.0, -676.0, 368.0),
  Vector(810.0, -673.0, 368.0),
  Vector(280.0, -1043.0, 368.0),
  Vector(273.0, -1035.0, 432.0),
  Vector(222.0, -977.0, 432.0),
  Vector(149.0, -952.0, 431.0),
  Vector(55.0, -1051.0, 288.0),
  Vector(-128.0, -1226.0, 364.0),
  Vector(-235.0, -1353.0, 362.0),
  Vector(-331.0, -1651.0, 388.0),
  Vector(-262.0, -2320.0, 272.0),
  Vector(-355.0, -2324.0, 235.0),
  Vector(-682.0, -2512.0, 238.0),
  Vector(-702.0, -2540.0, 243.0),
  Vector(-738.0, -2994.0, 192.0),
  Vector(-1137.0, -3138.0, 192.0),
  Vector(-1393.0, -2869.0, 75.0)
};

bool onSegment(Vector p, Vector q, Vector r){
	if (q.x <= Math.max(p.x, r.x) && q.x >= Math.min(p.x, r.x) && q.y <= Math.max(p.y, r.y) && q.y >= Math.min(p.y, r.y))
		return true;
	return false;
}

int orientation(Vector p, Vector q, Vector r){
	float val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y);
  
	if (val == 0.0) return 0;
	return (val > 0.0)? 1: 2;
}

bool doIntersect(Vector p1, Vector q1, Vector p2, Vector q2){
	int o1 = orientation(p1, q1, p2);
	int o2 = orientation(p1, q1, q2);
	int o3 = orientation(p2, q2, p1);
	int o4 = orientation(p2, q2, q1);
  
	if (o1 != o2 && o3 != o4) return true;
  
	if (o1 == 0 && onSegment(p1, p2, q1)) return true;
	if (o2 == 0 && onSegment(p1, q2, q1)) return true;
	if (o3 == 0 && onSegment(p2, p1, q2)) return true;
	if (o4 == 0 && onSegment(p2, q1, q2)) return true;
  
	return false;
}

bool isInside(Vector origin){
	Vector extreme = Vector(20000.0, origin.y, 0.0);

	int count = 0, i = 0;
  int n = play_area_instinct_9.length();
	do{
		int next = (i+1)%n;

		if (doIntersect(play_area_instinct_9[i], play_area_instinct_9[next], origin, extreme)){
      
			if (orientation(play_area_instinct_9[i], origin, play_area_instinct_9[next]) == 0)
        return onSegment(play_area_instinct_9[i], origin, play_area_instinct_9[next]);
      
			count++;
		}
		i = next;
	} while (i != 0);
  
	return (count%2 == 1);
}

float get_nearest_point_z(Vector origin){
  int n = play_area_instinct_9.length();
  int best_idx = -1;
  float best_distance = 99999.0f;
  for(int i = 0; i < n; i++){
    
    Vector new_vec;
    new_vec.x = origin.x - play_area_instinct_9[i].x;
    new_vec.y = origin.y - play_area_instinct_9[i].y;
    new_vec.z = origin.z - play_area_instinct_9[i].z;
    
    float new_distance = sqrt(
      new_vec.x * new_vec.x +
      new_vec.y * new_vec.y +
      new_vec.z * new_vec.z
    );
    
    if(new_distance < best_distance){
      best_distance = new_distance;
      best_idx = i;
    }
  }
  
  if(best_idx == -1) return 0;
  return play_area_instinct_9[best_idx].z;
}
