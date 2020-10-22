package com.pds.native_code;

import android.content.Context;
import android.os.Environment;
import android.widget.Toast;
import android.util.Log;

import org.opencv.core.Core;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.core.MatOfPoint;
import org.opencv.core.Point;
import org.opencv.core.Rect;
import org.opencv.core.Scalar;
import org.opencv.core.Size;
import org.opencv.imgcodecs.Imgcodecs;
import org.opencv.imgproc.Imgproc;

import java.io.*;
import java.util.ArrayList;

import static org.opencv.core.Core.bitwise_not;
import static org.opencv.core.Core.inRange;
import static org.opencv.imgcodecs.Imgcodecs.imread;
import static org.opencv.imgcodecs.Imgcodecs.imwrite;
import static org.opencv.imgproc.Imgproc.GC_INIT_WITH_RECT;
import static org.opencv.imgproc.Imgproc.MORPH_RECT;
import static org.opencv.imgproc.Imgproc.contourArea;
import static org.opencv.imgproc.Imgproc.cvtColor;
import static org.opencv.imgproc.Imgproc.drawContours;
import static org.opencv.imgproc.Imgproc.erode;
import static org.opencv.imgproc.Imgproc.findContours;
import static org.opencv.imgproc.Imgproc.getStructuringElement;
import static org.opencv.imgproc.Imgproc.threshold;

import com.tsi.blurimagedetector.ImageBlurrinessDetector;

public class ImageGrabCutService {
    //for segmentation
    public static void segmentation(String imagePath, String imageName) {

        try {
            Mat mask = imread(imagePath + File.separator + imageName);

            //Converting the source image to binary
            Mat gray = new Mat(mask.rows(), mask.cols(), mask.type());
            cvtColor(mask, gray, Imgproc.COLOR_BGR2GRAY);
            Mat binary = new Mat(mask.rows(), mask.cols(), mask.type(), new Scalar(0));
            threshold(gray, binary, 100, 255, Imgproc.THRESH_BINARY_INV);

            //Finding Contours
            ArrayList<MatOfPoint> contours = new ArrayList<>();
            Mat hierarchey = new Mat(mask.rows(), mask.cols(), mask.type(), new Scalar(0));
            int largest_contour_index = 0;
            int largest_area = 0;

            findContours(binary, contours, hierarchey, Imgproc.RETR_TREE,
                    Imgproc.CHAIN_APPROX_SIMPLE);
            //Drawing the Contours
            Scalar color = new Scalar(0, 0, 255);

            for (int i = 0; i < contours.size(); i++) // iterate through each contour.
            {
                double a = contourArea(contours.get(i), false);  //  Find the area of contour
                if (a > largest_area) {
                    largest_area = (int) a;
                    largest_contour_index = i;                //Store the index of largest contour
                }
            }

            drawContours(mask, contours, largest_contour_index, new Scalar(255, 255, 255), 2, Imgproc.LINE_8,
                    hierarchey, 2, new Point());

            int dilation_size = 2;
            Mat element = getStructuringElement(MORPH_RECT,
                    new Size(2 * dilation_size + 1, 2 * dilation_size + 1),
                    new Point(dilation_size, dilation_size));
            erode(mask, mask, element);

            Mat HSV = new Mat(), hsv_thr = new Mat(), dst = new Mat();
            cvtColor(mask, HSV, Imgproc.COLOR_BGR2HSV);
            inRange(HSV, new Scalar(20, 10, 10), new Scalar(90, 255, 255), hsv_thr);
            imwrite(imagePath + File.separator + "hsv_thr-" + imageName, hsv_thr);

            imwrite(imagePath + File.separator + "HSV-" + imageName, HSV);


            Mat maskOut = new Mat(mask.rows(), mask.cols(), CvType.CV_8UC1, new Scalar(0));
            bitwise_not(hsv_thr, dst);
            imwrite(imagePath + File.separator + "dst-" + imageName, dst);

            findContours(dst.clone(), contours, hierarchey,
                    Imgproc.RETR_EXTERNAL, Imgproc.CHAIN_APPROX_SIMPLE);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    //for grabCut
    public static String grabCutObject(Context context, String imagePath, String imageName) {
        try {
//        imagePath = getAbsolutePath(context);
            imagePath = new File(imagePath).getParent();
//        imageName = "early_blight.JPG";
            Log.e("OpenCV", "imagePath: " + imagePath + " imageName: " + imageName);
            System.out.println("imagePath: " + imagePath + " imageName: " + imageName);
            Mat origin = imread(imagePath + File.separator + imageName);
            Rect rectangle = new Rect(25, 25, origin.cols() - 64, origin.rows() - 64);
            Mat result = new Mat();
            Mat bgdModel = new Mat();
            Mat fgdModel = new Mat();
            Mat source = new Mat(1, 1, CvType.CV_8U, new Scalar(3));
            Imgproc.grabCut(origin, result, rectangle, bgdModel, fgdModel, 8, GC_INIT_WITH_RECT);
            Core.compare(result, source, result, Core.CMP_EQ);
            Mat foreground = new Mat(origin.size(), CvType.CV_8UC3, new Scalar(255, 255, 255));
            origin.copyTo(foreground, result);

            imageName = "grabcut-" + imageName;
            String imageFilePath = imagePath + File.separator + imageName;
            Imgcodecs.imwrite(imageFilePath, foreground);

            return imageFilePath;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public static boolean isBlurOrTooDark(Context context, String imageUploadFilePath, String uploadImageFileName) {
        try {
//        imageUploadFilePath = getAbsolutePath(context);
            imageUploadFilePath = new File(imageUploadFilePath).getParent();
//        uploadImageFileName = "early_blight.JPG";
            System.out.println("imageUploadFilePath: " + imageUploadFilePath + " uploadImageFileName: " + uploadImageFileName);
            boolean isBlurred = ImageBlurrinessDetector.isImageBlurred(uploadImageFileName, imageUploadFilePath);
            System.out.println("isBlurred: " + isBlurred);
            boolean isTooBrightOrDark = ImageBlurrinessDetector.isImageTooBrightOrTooDark(uploadImageFileName, imageUploadFilePath);
            System.out.println("isTooBrightOrDark: " + isTooBrightOrDark);
            if (isBlurred) {
                Toast.makeText(context, "The image is blur. Please take another picture", Toast.LENGTH_LONG).show();
                return true;
            } else if (isTooBrightOrDark) {
                Toast.makeText(context, "The image is too bright or dark. Please take another picture", Toast.LENGTH_LONG).show();
                return true;
            } else {
//                Toast.makeText(context, "The image is alright", Toast.LENGTH_SHORT).show();
                return false;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return true;
        }
    }

    public static String getAbsolutePath(Context context) {
        if (Environment.MEDIA_MOUNTED.equals(Environment.getExternalStorageState())) {
            return context.getExternalFilesDir(null).getAbsolutePath();
        } else {
            return context.getFilesDir().getAbsolutePath();
        }
    }
}
