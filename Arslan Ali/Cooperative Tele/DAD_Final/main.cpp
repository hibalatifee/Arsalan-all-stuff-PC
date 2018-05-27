#pragma once
#pragma warning(disable:4996)

#include <afxwin.h>      //MFC core and standard components
#include "afxext.h"         // MFC extensio
#include "resource.h"    //main symbols
#include <iostream>
#include <conio.h>
#include "Phantom_omni.h" 

using namespace std;

CButton * p_start;
CButton * p_init;
CButton * p_calib;
CButton * p_stop;
CEdit   * p_edit;

CStatic * p_disp;
CStatic * p_mf;
CStatic * p_sv;


class Phantom : public CDialog
{
public:
	Phantom(CWnd* pParent = NULL) : CDialog(Phantom::IDD, pParent)
	{}
	// Dialog Data, name of dialog form
	enum { IDD = IDD_DIALOG1};
protected:
	virtual void DoDataExchange(CDataExchange* pDX) 
	
	{ CDialog::DoDataExchange(pDX); }
	//Called right after constructor. Initialize things here.

	virtual BOOL OnInitDialog()
	{
		CDialog::OnInitDialog();
	
		p_start = (CButton *)GetDlgItem(CB_start);
		p_calib = (CButton *)GetDlgItem(CB_calibarate);
		p_init  = (CButton *)GetDlgItem(CB_initiliaze);
		p_stop  = (CButton *)GetDlgItem(CB_stop);
		
			return true;
	}
public:


	DECLARE_MESSAGE_MAP()
	afx_msg void OnBnClickedstart();
	afx_msg void OnBnClickedinitiliaze();
	afx_msg void OnBnClickedcalibarate();
	afx_msg void OnBnClickedstop();
	
	afx_msg void OnPaint();

	afx_msg void OnBnClickedtime();
	afx_msg void OnBnClickedcamera();
	afx_msg void OnBnClickedcamera2();
	afx_msg void OnBnClickedfixed();
	afx_msg void OnBnClickedDad();
	afx_msg void OnBnClickedconon();
	afx_msg void OnBnClickedconoff();
	afx_msg void OnBnClickedCancel();
};
//---------------------------------------------------------------------
class Phantom_winapp : public CWinApp
{
public:
	Phantom_winapp() {  }
public:
	virtual BOOL InitInstance()
	{
		CWinApp::InitInstance();
		Phantom dlg;
		m_pMainWnd = &dlg;
		INT_PTR nResponse = dlg.DoModal();
		return FALSE;
	} //Close function

};
//-----------------------For Message Handlers, identifiers and macros---------------------------
//Need a Message Map Macro for both CDialog and CWinApp
BEGIN_MESSAGE_MAP(Phantom, CDialog)   // phantom is owner class name, CDialog is a base class name

	ON_BN_CLICKED(CB_start, &Phantom::OnBnClickedstart)
	ON_BN_CLICKED(CB_initiliaze, &Phantom::OnBnClickedinitiliaze)
	ON_BN_CLICKED(CB_calibarate, &Phantom::OnBnClickedcalibarate)
	ON_BN_CLICKED(CB_stop, &Phantom::OnBnClickedstop)



	ON_BN_CLICKED(CB_camera, &Phantom::OnBnClickedcamera)
	ON_BN_CLICKED(CB_camera2, &Phantom::OnBnClickedcamera2)
	ON_BN_CLICKED(CB_fixed, &Phantom::OnBnClickedfixed)
	ON_BN_CLICKED(CB_DAD, &Phantom::OnBnClickedDad)
	ON_BN_CLICKED(CB_con_on, &Phantom::OnBnClickedconon)
	ON_BN_CLICKED(CB_con_off, &Phantom::OnBnClickedconoff)
	ON_BN_CLICKED(IDCANCEL, &Phantom::OnBnClickedCancel)
END_MESSAGE_MAP()
//-----------------------------------------------------------------------------------------


Phantom_winapp  theApp;  //Starts the Application



void Phantom::OnBnClickedstart()
{
	// TODO: Add your control notification handler code here
	//p_disp = (CStatic *)GetDlgItem(CS_disp);
	//p_disp->SetWindowText(L" You pressed Start Button");
	Start();
	
}

void Phantom::OnBnClickedinitiliaze()
{
	// TODO: Add your control notification handler code here
	rotation();
	Initiliaze();
	   //LARGE_INTEGER sPos;
	

	//freopen("CONIN$", "r", stdout); //reading from console window  
	
	//p_init = (CButton *)GetDlgItem(CB_initiliaze);
	//p_init->EnableWindow(FALSE);
}


void Phantom::OnBnClickedcalibarate()
{
	// TODO: Add your control notification handler code here
	Calibarate();

	//p_calib = (CButton *)GetDlgItem(CB_calibarate);
	//p_calib->EnableWindow(FALSE);

	
}


void Phantom::OnBnClickedstop()
{

	Close();

}


void Phantom::OnBnClickedcamera()
{
	// TODO: Add your control notification handler code here
}


void Phantom::OnBnClickedcamera2()
{
	// TODO: Add your control notification handler code here
}


void Phantom::OnBnClickedfixed()
{
	// TODO: Add your control notification handler code here
	switch_method=false;  // Fixed Dominance 
}


void Phantom::OnBnClickedDad()
{
	// TODO: Add your control notification handler code here
	switch_method=true;  // DAD
}


void Phantom::OnBnClickedconon()
{
	// TODO: Add your control notification handler code here
	AllocConsole();
	freopen("CONOUT$", "w", stdout);  //reopen stream with different file or mode 
	//freopen("CONIN$", "r", stdout); //reading from console window  
}


void Phantom::OnBnClickedconoff()
{
	// TODO: Add your control notification handler code here
		FreeConsole();
}


void Phantom::OnBnClickedCancel()
{
	// TODO: Add your control notification handler code here
	CDialog::OnCancel();
}
