//
//  main.cpp
//  cvmagic
//
//  Created by Alex on 4/15/13.
//  Copyright (c) 2013 Alex Leverington. All rights reserved.
//

#ifdef __OBJC__
#include <Foundation/Foundation.h>
#include <Cocoa/Cocoa.h>
#endif
#include <opencv/cvaux.h>
#include <opencv/cxcore.h>
#include <opencv/cxmisc.h>
#include <opencv/highgui.h>
#include <opencv/ml.h>

#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/calib3d/calib3d.hpp"
#include <iostream>
#include <stdio.h>
#include <stdlib.h>

using namespace std;
using namespace cv;

IplImage *img1;
IplImage *img=0;
IplImage *img1_b;
IplImage *img_b=0;
 
unsigned char *RGBtoGray(IplImage *img)
{
    img1 = cvCreateImage(cvGetSize(img),IPL_DEPTH_8U,1);
    //色彩空间转换，将源彩色图像img转化成目标灰色图像imag1
    cvCvtColor(img,img1,CV_BGR2GRAY);  
    return 0;
    
}
unsigned char *RGBtoGray_b(IplImage *img_b)
{
    img1_b = cvCreateImage(cvGetSize(img_b),IPL_DEPTH_8U,1);
    //色彩空间转换，将源彩色图像img转化成目标灰色图像imag1_b
    cvCvtColor(img_b,img1_b,CV_BGR2GRAY);  
    return 0;
    
}

// OSTU算法求出阈值
int ImgPro4Binary_Otsu(unsigned char* pGrayImg , int iWidth , int iHeight)

{
    if((pGrayImg==0)||(iWidth<=0)||(iHeight<=0))return -1;
    int ihist[256]; 
    int thresholdValue=0; // „–÷µ
    int n, n1, n2 ;
    double m1, m2, sum, csum, fmax, sb;
    int i,j,k;
    memset(ihist, 0, sizeof(ihist));
    n=iHeight*iWidth;
    sum = csum = 0.0;
    fmax = -1.0;
    n1 = 0;
    for(i=0; i < iHeight; i++)
    {        
        for(j=0; j < iWidth; j++)
        {            
            ihist[*pGrayImg]++;
            pGrayImg++;  
        }
    }
    pGrayImg -= n; 
    for (k=0; k <= 255; k++)
    {
        sum += (double) k * (double) ihist[k];
    }    
    for (k=0; k <=255; k++)
    {
        n1 += ihist[k];
        if(n1==0)continue;
        n2 = n - n1;
        if(n2==0)break;
        csum += (double)k *ihist[k];
        m1 = csum/n1; 
        m2 = (sum-csum)/n2; 
        sb = (double) n1 *(double) n2 *(m1 - m2) * (m1 - m2);
        if (sb > fmax)
        {
            fmax = sb;
            thresholdValue = k;
        }
    }
    return(thresholdValue);
}

 /** @function main */
int main( int argc, char** argv )
{
    int i=0 ,h,w,s,w_b,h_b; // s:总的像素点
	int count = 0;        // 笔占的像素点
	int threshold,threshold_b;
	unsigned char *datad,*datad_b;
	float area_b=0,area_all; // area_b:笔的面积  area_all:总面积
	area_all=13.3*14.8;// 随意取值，可改
  
    img = cvLoadImage("/Users/sinosoft/Desktop/1.jpg");// 原始图片
    RGBtoGray(img);
    img_b = cvLoadImage("/Users/sinosoft/Desktop/3.jpg");// 第二张图片
    RGBtoGray_b(img_b);
    
    
    w=img1->width;
    h=img1->height;
    w_b=img1_b->width;
    h_b=img1_b->height;
    s=img1->imageSize;//¥Û–°
    
    
    datad=(unsigned char*)img1->imageData;// img1为灰度图
    datad_b=(unsigned char*)img1_b->imageData;
    
    threshold = ImgPro4Binary_Otsu(datad, w, h);

    threshold_b=ImgPro4Binary_Otsu(datad_b,w_b,h_b);
    printf("阈值大小：%d\n",threshold);
    // 二值化过程
    for(i=0;i<s;i++)
    {
        if((*(datad+i))>=threshold)
            *(datad+i)=255;
        else
            *(datad+i)=0;
    }
    for(i=0;i<s;i++)
    {
        if((*(datad_b+i))>=threshold_b)
            *(datad_b+i)=255;
        else
            *(datad_b+i)=0;
    }
    for(i=0;i<s;i++)
    {
        if((*(datad_b+i))!=(*(datad+i)))
            count++;
        
    }
    area_b=((float)count/307200)*area_all;
    
    printf("笔所占的像素点为为：%d个像素点\n",count);
    printf("总的像素点为为：%d个像素点\n",s);
    printf("总的面积：%.2f平方厘米\n",area_all);
    printf("笔所占面积：%.2f平方厘米\n",area_b);
    
    cvNamedWindow("GrayImage",CV_WINDOW_AUTOSIZE);//创建窗口，窗口名字GrayImage
    cvNamedWindow("Example4-in");
    cvNamedWindow("GrayImage_b",CV_WINDOW_AUTOSIZE);//创建窗口，窗口名字GrayImage
    cvNamedWindow("Example4-in_b");
    
    cvShowImage("GrayImage",img1);//载入转化后的图像
    cvShowImage("Example4-in",img);
    cvShowImage("GrayImage_b",img1_b);//载入转化后的图像
    cvShowImage("Example4-in_b",img_b);
    cvReleaseImage(&img1);
    cvReleaseImage(&img);
    cvReleaseImage(&img1_b);
    cvReleaseImage(&img_b);
    
    cvWaitKey(0);//等待用户按下一个按键
    cvDestroyWindow("GrayImage");
    cvDestroyWindow("Example4-in");
    cvDestroyWindow("GrayImage_b");
    cvDestroyWindow("Example4-in_b");
    
    return(0);
}


 
 
