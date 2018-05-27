#pragma once
#include "Global.h"
using namespace std;

//HHD Master1 = hdInitDevice("master1");  // Master #1 initilization

//HHD Master2 = hdInitDevice("master2");   // Master #2 initilization

//HHD Slave = hdInitDevice("slave");   // Slave initilization

/*******************************************************************************
Call Backs
*******************************************************************************/
HDCallbackCode HDCALLBACK DeviceCalibrate(void *pUserData)
{
	hdBeginFrame(Master1);
	hdGetDoublev(HD_CURRENT_POSITION, init_position[0]);
	hdEndFrame(hdGetCurrentDevice());

	hdBeginFrame(Master2);
	hdGetDoublev(HD_CURRENT_POSITION, init_position[1]);
	hdEndFrame(hdGetCurrentDevice());
	
	hdBeginFrame(Slave);
	hdGetDoublev(HD_CURRENT_POSITION, init_position[2]);
	hdEndFrame(hdGetCurrentDevice());

	return HD_CALLBACK_DONE;
}

//----------------------------Device Asynchronous Callback----------------------

HDCallbackCode HDCALLBACK Start_teleoperation(void *pUserData)

{
	if (omni_cnt <2000)   //delay of 2 sec
	{
		omni_cnt++;
	}

	else

	{

		QueryPerformanceFrequency(&freq);   
		omni_cnt++;
		QueryPerformanceCounter(&sPos);    
		
		ms_interval = (sPos.QuadPart - ePos.QuadPart)/(freq.QuadPart/1000000); //one rotune time
		ePos = sPos;

		Fixed_Dominance();
		DAD_Algorithm();
		save_data();
		time_note();
		time_tick++;   
		t1++;
	}

	return HD_CALLBACK_CONTINUE;
}
/*******************************************************************************
Functions
*******************************************************************************/

void Initiliaze(void)
{

#ifdef DEVICE_NAME_1
	Master1 = hdInitDevice(DEVICE_NAME_1);
	hdEnable(HD_FORCE_OUTPUT);
#endif
	
#ifdef DEVICE_NAME_2
	Master2 = hdInitDevice(DEVICE_NAME_2);
	hdEnable(HD_FORCE_OUTPUT);
#endif

#ifdef DEVICE_NAME_2
	Slave = hdInitDevice(DEVICE_NAME_3);
	hdEnable(HD_FORCE_OUTPUT);
#endif

	hdStartScheduler();
	
	for (int i = 0; i<3; i++)
	{
		for (int j = 0; j<=2; j++)
		
		{
			force[j][i] = 0.0;
			position[j][i] = 0.0;
			init_position[j][i] = 0.0;
		}
		
		mst1.prev[i] = 0.0;
		mst1.position[i] = 0.0;
		mst1.force[i] = 0.0;
		mst1.disp[i] = 0.0;

		mst2.prev[i] = 0.0;
		mst2.position[i] = 0.0;
		mst2.force[i] = 0.0;
		mst2.disp[i] = 0.0;

		slv.prev[i] = 0.0;
		slv.position[i] = 0.0;
		slv.force[i] = 0.0;
		slv.disp[i] = 0.0;

		diff_e1[i] = 0.0;   prev_e1[i] = 0.0;	
		diff_e2[i] = 0.0;	prev_e2[i] = 0.0;
		
		n[i] = 0.0;
	}

	alpha[0] = 0.5;	alpha[1] = 0.5;	alpha[2] = 0.5;  

	energy_user1[0] = 0.0;	energy_user1[1] = 0.0;	energy_user1[2] = 0.0;
	energy_user2[0] = 0.0;	energy_user2[1] = 0.0;	energy_user2[2] = 0.0;

	omni_cnt = 0;
	time_tick=0;
	
	Phantom_Started = false;
}

//----------------------------------------------------------------------------
void rotation(void)
{

	theta1_y*= DEGTORAD;    
	theta2_y*= DEGTORAD;    

	Rotation1(0,0)=cos(theta1_y);      Rotation1(0,1)= 0;	  Rotation1(0,2)=sin(theta1_y);
	Rotation1(1,0)=0;				   Rotation1(1,1)=1;	  Rotation1(1,2)=0;
	Rotation1(2,0)=-sin(theta1_y);     Rotation1(2,1)=0;      Rotation1(2,2)=cos(theta1_y);

	Rotation2(0,0)=cos(theta2_y);      Rotation2(0,1)= 0;	  Rotation2(0,2)=sin(theta2_y);
	Rotation2(1,0)=0;				   Rotation2(1,1)=1;	  Rotation2(1,2)=0;
	Rotation2(2,0)=-sin(theta2_y);     Rotation2(2,1)=0;      Rotation2(2,2)=cos(theta2_y);

	R1_inv=Rotation1.transpose();
	R2_inv=Rotation2.transpose();
	
}
//----------------------------------------------------------------------------

void Calibarate(void)
{
	if (!Phantom_Started) 
	{
		hdScheduleSynchronous(DeviceCalibrate, 0, HD_MIN_SCHEDULER_PRIORITY);
	}
}
//----------------------------------------------------------------------------
inline void time_note (void)
{

	     if (_kbhit())
	{
		 keypress = toupper(getch());

	        if (keypress == '1')
            {
                File_Time<<t1<<endl;
				cout<<t1<<endl;
	
				t1=0;
				

            }
            else if (keypress == '2')
            {
                
				File_Time<<t1<<endl;
				cout<<t1<<endl;
				t1=0;
				
            }
            else if (keypress == '3')
            {
               	File_Time <<t1<<endl;
				cout<<t1<<endl;
				t1=0;
			
            }
            else if (keypress == '4')
            {
              	File_Time<<t1<<endl;
				cout<<t1<<endl;
				t1=0;
		
            }
            else if (keypress == '5')
            {
                File_Time<<t1<<endl;
				cout<<t1<<endl;
				t1=0;
			
            }
			else
			{}
	}

}

//----------------------------------------------------------------------------

void Start(void)
{
	if (!Phantom_Started)
	{
		Phantom_Started = true;
        teleoperation= hdScheduleAsynchronous(Start_teleoperation, 0, HD_DEFAULT_SCHEDULER_PRIORITY);
	}
}

//----------------------------------------------------------------------------

void Close (void)
{
	hdStopScheduler();
	hdUnschedule(teleoperation);
	hdDisableDevice(Master1);
	hdDisableDevice(Master2);
	hdDisableDevice(Slave);

	File_Position.close();
	File_Force.close();
	File_Velocity.close();
	File_Energy.close();
	File_Dominance.close();
	File_Time.close();

}
//---------------------------------------------------------------------------

inline void  Fixed_Dominance() //Slave (Phantom Premium)

{

/*******************************************************************************
Master #1
*******************************************************************************/
	hdBeginFrame(Master1);

    mst1.prev[0] = mst1.position[0];
	mst1.prev[1] = mst1.position[1];
	mst1.prev[2] = mst1.position[2];

	hdGetDoublev(HD_CURRENT_POSITION, mst1.position);
	hdGetIntegerv(HD_CURRENT_BUTTONS, &button);
	//hdGetDoublev(HD_CURRENT_VELOCITY, mst1.velocity);
	//hdGetDoublev(HD_NOMINAL_MAX_FORCE, slv.maxforce);

	mst1.position[0] = mst1.position[0] - init_position[0][0];
	mst1.position[1] = mst1.position[1] - init_position[0][1];
	mst1.position[2] = mst1.position[2] - init_position[0][2];
	
	mst1.disp[0] = (mst1.position[0] - mst1.prev[0]);	
	mst1.disp[1] = (mst1.position[1] - mst1.prev[1]);
	mst1.disp[2] = (mst1.position[2] - mst1.prev[2]);	

	m1(0)=mst1.position[0]; 
	m1(1)=mst1.position[1];
	m1(2)=mst1.position[2];

	m1_p=Rotation1 *m1;

/*******************************************************************************
Master #2
*******************************************************************************/
	hdBeginFrame(Master2);
    
	mst2.prev[0] = mst2.position[0];
	mst2.prev[1] = mst2.position[1];
	mst2.prev[2] = mst2.position[2];

	hdGetDoublev(HD_CURRENT_POSITION, mst2.position);
	//hdGetDoublev(HD_CURRENT_VELOCITY, mst2.velocity);

	mst2.position[0] = mst2.position[0]- init_position[1][0];
	mst2.position[1] = mst2.position[1]- init_position[1][1];
	mst2.position[2] = mst2.position[2]- init_position[1][2];

	mst2.disp[0] = mst2.position[0] - mst2.prev[0];   
	mst2.disp[1] = mst2.position[1] - mst2.prev[1];   
	mst2.disp[2] = mst2.position[2] - mst2.prev[2];	

	m2(0)=mst2.position[0]; 
	m2(1)=mst2.position[1];
	m2(2)=mst2.position[2];

	m2_p=Rotation2 *m2;
/*******************************************************************************
Slave
*******************************************************************************/
	hdBeginFrame(Slave);

	slv.prev[0] = slv.position[0];
	slv.prev[1] = slv.position[1];
	slv.prev[2] = slv.position[2];
	 
	hdGetDoublev(HD_CURRENT_POSITION, slv.position);
	//hdGetDoublev(HD_CURRENT_VELOCITY, slv.velocity);

	slv.position[0] = slv.position[0] - init_position[2][0];
	slv.position[1] = slv.position[1] - init_position[2][1];
	slv.position[2] = slv.position[2] - init_position[2][2];
	
	slv.disp[0] = slv.position[0] - slv.prev[0]; 
	slv.disp[1] = slv.position[1] - slv.prev[1];
	slv.disp[2] = slv.position[2] - slv.prev[2];

	s(0)=slv.position[0]; 
	s(1)=slv.position[1];
	s(2)=slv.position[2];

	SP1=R1_inv*s;
	SP2=R2_inv*s;

	combine_x = m1_p(0)*alpha[0] + m2_p(0)*(1-alpha[0]);
	combine_y = m1_p(1)*alpha[1] + m2_p(1)*(1-alpha[1]);
	combine_z = m1_p(2)*alpha[2] + m2_p(2)*(1-alpha[2]);

/*******************************************************************************
Forces
*******************************************************************************/
	
	slv.force[0] =  Omni_Saturation(Stifness*(combine_x - slv.position[0]));
	slv.force[1] =  Omni_Saturation(Stifness*(combine_y - slv.position[1]));
	slv.force[2] =  Omni_Saturation(Stifness*(combine_z - slv.position[2]));
		
    mst1.force[0] =  -1 * Omni_Saturation(Stifness*(mst1.position[0] - SP1(0)));
	mst1.force[1] =  -1 * Omni_Saturation(Stifness*(mst1.position[1] - SP1(1)));
	mst1.force[2] =  -1 * Omni_Saturation(Stifness*(mst1.position[2] - SP1(2)));
	
	mst2.force[0] =  -1 * Omni_Saturation(Stifness*(mst2.position[0] - SP2(0)));
	mst2.force[1] =  -1 * Omni_Saturation(Stifness*(mst2.position[1] - SP2(1)));
	mst2.force[2] =  -1 * Omni_Saturation(Stifness*(mst2.position[2] - SP2(2)));


	hdMakeCurrentDevice(Slave);
	hdSetDoublev(HD_CURRENT_FORCE, slv.force);

	hdMakeCurrentDevice(Master1);
	hdSetDoublev(HD_CURRENT_FORCE, mst1.force);

	hdMakeCurrentDevice(Master2);
	hdSetDoublev(HD_CURRENT_FORCE, mst2.force);
	
	hdEndFrame(Slave);
	hdEndFrame(Master1);
	hdEndFrame(Master2);

}
//----------------------------------------------------------------------------
int Compare_data(double a, double b, double c)
{
	if(a < b && a < c)
	{
		return 0;
	}
	else if(b < a && b < c)
	{
		return 1;
	}else if(c < a && c < b)
	{
		return 2;
	}
	return -1;
}
//----------------------------------------------------------------------------
inline void DAD_Algorithm()
	{
	
	time_interval = time_interval + ms_interval;
	
	m1f(0) = mst1.force[0];   	m1f(1) = mst1.force[1];	    m1f(2) = mst1.force[2];	
    m1v(0) = mst1.disp[0];	    m1v(1) = mst1.disp[1];   	m1v(2) = mst1.disp[2];	

	m2f(0) = mst2.force[0];	    m2f(1) = mst2.force[1];	    m2f(2) = mst2.force[2];	
	m2v(0) = mst2.disp[0];	    m2v(1) = mst2.disp[1];	    m2v(2) = mst2.disp[2];	

	m1f = Rotation1 * m1f;	m1v = Rotation1 * m1v;
	m2f = Rotation2 * m2f;	m2v = Rotation2 * m2v;

		for(int i=0; i<3; i++)
			{
				energy_user1[i] = energy_user1[i] + (m1f(i)*m1v(i));
				energy_user2[i] = energy_user2[i] + (m2f(i)*m2v(i));

			}

		//if (switch_method==true)
		
		//{

		if(first_routin == false)
				{
					first_routin = true;
					prev_t = time_interval;
				}

		diff_time = time_interval - prev_t;

		if (diff_time > 300) 
			{
				prev_t = time_interval;


		for (int i = 0; i < 3; ++i)
			{
				diff_e1[i] = prev_e1[i] - energy_user1[i];
				diff_e2[i] = prev_e2[i] - energy_user2[i];

				prev_e1[i] = energy_user1[i];
				prev_e2[i] = energy_user2[i];
			}

	
		int k = Compare_data(diff_e1[0],diff_e1[1],diff_e1[2]);
				
					if(k != -1)
					{
						if(diff_e1[k] < 0 && diff_e2[k] > 0)
						{
							 if((diff_e2[k] - diff_e1[k]) > 0.001)
							 	n[k] = n[k] - INCREMENTAL;
							 alpha[k] = 0.5 + 0.4*tanh(n[k]);
								
							 if(n[k] < -3)
								n[k] = -3;
							 
							/*alpha[k] -= 0.001; 
								
						

							if(alpha[k] < 0.1)
								alpha[k] = 0.1;*/
						}
						else if(diff_e1[k] > 0 && diff_e2[k] < 0)
						{	
							 if((diff_e1[k] - diff_e2[k]) > 0.001)
							 	n[k] = n[k] + INCREMENTAL;
							 alpha[k] = 0.5 + 0.4*tanh(n[k]);
							 if(n[k] > 3)
							 	n[k] = 3;
						/*	alpha[k] += 0.001;   
								
							if(alpha[k] > 0.9)
								alpha[k] = 0.9;
						*/}
					
					}

					k = Compare_data(diff_e2[0],diff_e2[1],diff_e2[2]);
					if(k != -1)
					{
						if(diff_e1[k] < 0 && diff_e2[k] > 0)
						{
							if((diff_e2[k] - diff_e1[k]) > 0.001)
							 	n[k] = n[k] - INCREMENTAL;
							alpha[k] = 0.5 + 0.4*tanh(n[k]);
								
							 if(n[k] < -3)
							 	n[k] = -3;
							/*alpha[k] -= 0.001;
								
							if(alpha[k] < 0.1)
								alpha[k] = 0.1;*/
						}
						else if(diff_e1[k] > 0 && diff_e2[k] < 0)
						{
							if((diff_e1[k] - diff_e2[k]) > 0.001)
								n[k] = n[k] + INCREMENTAL;
							 alpha[k] = 0.5 + 0.4*tanh(n[k]);
							if(n[k] > 3)
							 	n[k] =3;
							/*alpha[k] += 0.001;
								
							if(alpha[k] > 0.9)
								alpha[k] = 0.9;*/
						}
					}
				}
		//}
}

//----------------------------------------------------------------------------
 
inline void save_data()

{
	File_Position << m1_p[0]<<" "<<m1_p[1]<<" "<<m1_p[2]<<" "<<m2_p[0]<<" "<<m2_p[1]<<" "<<m2_p[2]<<" "<<slv.position<<endl;

	File_Energy<<energy_user1[0]<<" "<<energy_user1[1]<<"  "<<energy_user1[2]<<" "<<energy_user2[0]<<" "<<energy_user2[1]<<" "<<energy_user2[2]<<endl;

	File_Force<<mst1.force<<'\t'<<mst2.force<<'\t'<<slv.force<<endl;

	File_Velocity<<mst1.disp<<'\t'<<mst2.disp<<'\t'<<slv.disp<<endl;

	File_Dominance<<alpha[0]<<'\t'<<alpha[1]<<'\t'<<alpha[2]<<endl;
}
//----------------------------------------------------------------------------
double Omni_Saturation(double force)
{
	if (force<-LIMIT_FORCE_Omni)

		force = -LIMIT_FORCE_Omni;

	if (force>LIMIT_FORCE_Omni)
		
		force = LIMIT_FORCE_Omni;

	return force;
}

//----------------------------------------------------------------------------
double premium_Saturation(double force)
{
	if (force<-LIMIT_FORCE_Premium)

		force = -LIMIT_FORCE_Premium;

	if (force>LIMIT_FORCE_Premium)
		
		force = LIMIT_FORCE_Premium;

	return force;
}
/*****************************************************************************/
