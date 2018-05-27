//Define all variables here
#pragma once
//---------------------------------------------------------------
#include<iostream>
#include<fstream>
#include <stdlib.h>
#include <conio.h>
#include <math.h>

#include <HD/hd.h>
#include <HDU/hduVector.h>
#include <HDU/hduError.h>

#include <Eigen/Dense>

using namespace std;
using namespace Eigen;

ofstream File_Position("Position.txt");
ofstream File_Force("Force.txt");
ofstream File_Velocity("Velocity.txt");
ofstream File_Dominance("Dominance.txt");
ofstream File_Energy("Energy.txt");
ofstream File_Time("Time.txt");

#define DEVICE_NAME_1  "master1"
#define DEVICE_NAME_2  "master2"
#define DEVICE_NAME_3  "slave"

#define RADTODEG	180/M_PI
#define DEGTORAD	M_PI/180

#define LIMIT_FORCE_Omni      2.5
#define LIMIT_FORCE_Premium   3.5

#define Stifness		0.1
#define INCREMENTAL		0.001

HHD Master1,Master2,Slave ; //  Phantom Initilizations
//HHD Master = hdInitDevice("Master");
//HHD Slave = hdInitDevice("Slave");

hduVector3Dd position[3], force[3], angles[3];
hduVector3Dd init_position[3], init_angles[3];

double energy_user1[3], energy_user2[3];
double diff_e1[3], diff_e2[3], prev_e2[3], prev_e1[3];
double alpha[3];
double n[3];
double a[3];

Vector3d m1,m2,s,m1_p,m2_p;
Vector3d SP1,SP2;
Vector3d m1f,m1v;
Vector3d m2f,m2v;

Matrix3d Rotation1,Rotation2;
Matrix3d R1_inv,R2_inv;

int omni_cnt;
int time_tick=0;

bool Phantom_Started;
bool switch_method = false;

 LARGE_INTEGER sPos, ePos, freq;

__int64 ms_interval=0;
long int time_interval=0;
long int diff_time=0;
long int prev_t=0;

bool first_routin=false;

typedef struct _PACK {
	hduVector3Dd position;
	hduVector3Dd force;
	hduVector3Dd prev;
	hduVector3Dd disp;
	hduVector3Dd velocity;
	hduVector3Dd angle;
	hduVector3Dd maxforce;

}PACK;

PACK mst1, mst2, slv;


void Initiliaze(void);
void Calibarate(void);
void Start(void);
void Close(void);
int Compare_data(double a, double b, double c);
double Omni_Saturation(double force);
double premium_Saturation(double force);

inline void DAD_Algorithm();
inline void Fixed_Dominance();
inline void time_note();
inline void save_data();


double combine_x = 0;
double combine_y = 0;
double combine_z = 0;

HDSchedulerHandle teleoperation;

int keypress;

int t1,t2,t3,t4,t5=0;

double theta1_y= 270;
double theta2_y= 0;

HDint button;

