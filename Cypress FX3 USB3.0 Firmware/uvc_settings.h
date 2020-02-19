/*
 * uvc_settings.h
 *
 *  Created on: Jan 25, 2020
 *      Author: gaurav
 */

#ifndef UVC_SETTINGS_H_
#define UVC_SETTINGS_H_


#define WBVAL(x) (x & 0xFF),((x >> 8) & 0xFF)
#define DBVAL(x) (x & 0xFF),((x >> 8) & 0xFF),((x >> 16) & 0xFF),((x >> 24) & 0xFF)

#define UVC_WIDTH                                     (unsigned int)1280

#define UVC_HEIGHT                                    (unsigned int)720
#define CAM_FPS                                       33
#define MIN_BIT_RATE                                  (unsigned long)(UVC_WIDTH*UVC_HEIGHT*16*CAM_FPS)//16 bit
#define MAX_BIT_RATE                                  (unsigned long)(UVC_WIDTH*UVC_HEIGHT*16*CAM_FPS)
#define MAX_FRAME_SIZE                                (unsigned long)(UVC_WIDTH*UVC_HEIGHT*2)//yuy2
#define INTERVAL                                      (unsigned long)(10000000/CAM_FPS)


#endif /* UVC_SETTINGS_H_ */
