# MIPI CSI-2 Receiver on FPGA , USB 3.0 UVC 2Gbps Video Stream Over Cypress FX3

This Repo contains hardware, Verilog source and USB3.0 USB video device class (UVC) Controller C source for generic FPGA CSI receiver. No FPGA hardware specific components has been used so can be easily ported to any low cost FPGA. 

Supports Frame Rate from 15 to 1000 FPS , Resolution From 640x80 to Full 8M 3280x2464.<br>
Max data rate ~2Gbps at 1080p 60FPS. <br>
Full control of Frame rate and Resolution over UVC control. Manual Exposure and manual Brightness control for now. Manual exposure is mapped to UVC saturation Control. Test Pattern can also be enabled with mapped gamma control. 

Test Has been done at</br>
3280x2464 15FPS</br>
1920x1080 60FPS</br>
1920x1080 30FPS</br>
1280x720  120FPS</br>
1280x720  60FPS</br>
1280x720  30FPS</br>
640x480   200FPS</br>
640x480   30FPS</br>
640x128   682FPS</br>
640x80    1000FPS</br>

TODO: Improvements need to be done at FPGA side to implement auto exposure, Brightness and white Balance correction. 

MIPI CSI-2 Receiver on Lattice FPGA (c) by Gaurav Singh www.CircuitValley.com
MIPI CSI-2 Receiver on Lattice FPGA is licensed under a
Creative Commons Attribution 3.0 Unported License.
You should have received a copy of the license along with this
work.  If not, see <http://creativecommons.org/licenses/by/3.0/>.

Shield: [![CC BY 4.0][cc-by-shield]][cc-by]

This work is licensed under a [Creative Commons Attribution 4.0 International
License][cc-by].

[![CC BY 4.0][cc-by-image]][cc-by]

[cc-by]: http://creativecommons.org/licenses/by/4.0/
[cc-by-image]: https://i.creativecommons.org/l/by/4.0/88x31.png
[cc-by-shield]: https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg

## Camera module 

https://www.circuitvalley.com/2020/02/diy-imx219-4-lane-mipi-breakout-board-raspberry-pi-camera-fpga-4-lane-mipi-csi.html

https://www.circuitvalley.com/2020/02/imx219-camera-mipi-csi-receiver-fpga-lattice-raspberry-pi-camera.html




## Project Video
<a href="https://www.youtube.com/watch?v=HxytsTGWODs">
<img src="https://raw.githubusercontent.com/circuitvalley/mipi_csi_receiver_FPGA/master/Hardware/Lattice%20MachXO3%20USB3%20FX3%20Interface%20Board/diy_imx219_mipi_csi_camera_fpga_machxo3lf.JPG" alt="IMX219" width="830" height="560">
</a>



## Sensor Board Video 
<a href="https://www.youtube.com/watch?v=GFmE3KYa5zs">
<img src="https://raw.githubusercontent.com/circuitvalley/mipi_csi_receiver_FPGA/master/Hardware/IMX219/diy_imx219_board_4_lane_mipi_csi_raspberrypi_camera_fpga_mipi_csi%20(3)%20(1).JPG " alt="IMX219" width="480" height="480">
</a>


## Sensor Image Qaulity Video 

<a href="https://www.youtube.com/watch?v=uRaHXo-Zu90">
<img src="https://github.com/circuitvalley/mipi_csi_receiver_FPGA/blob/master/Hardware/Lattice%20MachXO3%20USB3%20FX3%20Interface%20Board/Full_frame_imx219_image.png" alt="IMX219" width="640" height="480">
</a>

