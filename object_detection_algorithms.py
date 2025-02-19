#!/usr/bin/env python
# coding: utf-8

# In[4]:
from pathlib import Path
import cv2
import numpy as np
import argparse
import sys
from skimage.io import imread, imsave
from skimage import data
from skimage.filters.rank import entropy
from skimage.morphology import disk
from matplotlib import pyplot as plt
from skimage.transform import probabilistic_hough_line



# In[5]:


import datetime
from datetime import datetime
import os
import six.moves.urllib as urllib
import sys
import tarfile
import tensorflow as tf
import zipfile
import pathlib
from collections import defaultdict
from io import StringIO
from PIL import Image
from IPython.display import display
from object_detection.utils import ops as utils_ops
from object_detection.utils import label_map_util
from object_detection.utils import visualization_utils as vis_util


# In[6]:


def timeit(func):
    def wrapper(*args,**kwargs):
        time_before = datetime.now()
        result = func(*args, **kwargs)
        # print(func.__name__ + ' - ' + str(datetime.now() - time_before))
        return result
    return wrapper


# In[7]:


@timeit
def save_image(image, image_path, method):
    imsave(new_image_path, image)


# In[8]:


@timeit
def find_objects_by_edges(image_path, new_image_path, params):
    hough_line_color = params["hough_line_color"]
    hough_mode = params["hough_mode"]
    blur_strength = params["blur_strength"]
    canny_lower = params["canny_lower"]
    canny_upper = params["canny_upper"]
    hough_line_length = params["hough_line_length"]
    hough_line_treshold =  params["hough_line_treshold"]
    hough_line_gap =  params["hough_line_gap"]
    hough_circle_min_radius = params["hough_circle_min_radius"]
    hough_circle_max_radius = params["hough_circle_max_radius"]
    hough_circle_param1 = params["hough_circle_param1"]
    hough_circle_param2 = params["hough_circle_param2"]
    hough_circle_min_dist = params["hough_circle_min_dist"]
    img = imread(image_path)
    blur = cv2.medianBlur(img,blur_strength)
    edges = cv2.Canny(blur, canny_lower, canny_upper, apertureSize=3)
    if hough_mode == "lines":
      lines = probabilistic_hough_line(edges, threshold=hough_line_treshold, line_length=hough_line_length, line_gap=hough_line_gap)
      line_r = int(hough_line_color[0])
      line_g = int(hough_line_color[1])
      line_b = int(hough_line_color[2])
      for line in lines:
          p0, p1 = line
          cv2.line(img,(p0[0], p0[1]),(p1[0], p1[1]),(line_r, line_g, line_b), 2)
    elif hough_mode == "circles":
      circles = cv2.HoughCircles(edges,cv2.HOUGH_GRADIENT,1,hough_circle_min_dist, param1=hough_circle_param1,param2=hough_circle_param2,minRadius=hough_circle_min_radius,maxRadius=hough_circle_max_radius)
      if circles is not None:
          circles = np.uint16(np.around(circles))
          for i in circles[0,:]:
                # draw the outer circle
            cv2.circle(img,(i[0],i[1]),i[2],(255,255,0),5)
            # draw the center of the circle
            cv2.circle(img,(i[0],i[1]),2,(255,0,255),3)
    elif hough_mode == "lines_and_circles":
      lines = probabilistic_hough_line(edges, threshold=hough_line_treshold, line_length=hough_line_length, line_gap=hough_line_gap)
      for line in lines:
          p0, p1 = line
          cv2.line(img,(p0[0], p0[1]),(p1[0], p1[1]),(255, 0, 255), 2)
      circles = cv2.HoughCircles(edges,cv2.HOUGH_GRADIENT,1,hough_circle_min_dist, param1=hough_circle_param1,param2=hough_circle_param2,minRadius=hough_circle_min_radius,maxRadius=hough_circle_max_radius)
      if circles is not None:
          circles = np.uint16(np.around(circles))
          for i in circles[0,:]:
                # draw the outer circle
            cv2.circle(img,(i[0],i[1]),i[2],(255,255,0),5)
            # draw the center of the circle
            cv2.circle(img,(i[0],i[1]),2,(255,0,255),3)
    # display(Image.fromarray(img))
    save_image(img, new_image_path, "edges")



# In[11]:


@timeit
def find_objects_viola_jones(image_path, new_image_path, params):
    object_type = params["object_type"]
    min_neighbors = params["min_neighbors"]
    scale_factor = params["scale_factor"]
    if object_type in ["cars", "airplanes", "trains"]:
        img = imread(image_path)
        haar_cascade_src = f'/home/sergey/Рабочий стол/sfedu/images/haar_cascades/{object_type}.xml'
        haar_cascade = cv2.CascadeClassifier(haar_cascade_src)
        if len(img.shape) == 3:
            gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        else:
            gray = img
        cars = haar_cascade.detectMultiScale(gray, scale_factor, min_neighbors)
        for (x, y, w, h) in cars:
            cv2.rectangle(img, (x,y), (x+w, y+h), (0, 0, 255), 2)
        # display(Image.fromarray(img))
        save_image(img, new_image_path, "haar")


# In[12]:


@timeit
def load_model(model_name):
  base_url = 'http://download.tensorflow.org/models/object_detection/'
  model_file = model_name + '.tar.gz'
  path, dirs, files = next(os.walk("/home/sergey/Elixir/object_detection/models/"))
  model_dir = tf.keras.utils.get_file(
    fname= model_name,
    origin=base_url + model_file,
    untar=True)

  model_dir = pathlib.Path(model_dir)/"saved_model"

  model = tf.saved_model.load(str(model_dir))
  model = model.signatures['serving_default']
  return model

@timeit
def find_objects_tensorflow(image_path, new_image_path, params):
    # patch tf1 into `utils.ops`
    utils_ops.tf = tf.compat.v1

    # Patch the location of gfile
    tf.gfile = tf.io.gfile

    if "models" in pathlib.Path.cwd().parts:
      while "models" in pathlib.Path.cwd().parts:
        os.chdir('..')
    elif not pathlib.Path('models').exists():
      os.system('git clone --depth 1 https://github.com/tensorflow/models')
    # model_name = "mask_rcnn_inception_resnet_v2_atrous_coco_2018_01_28"
    # masking_model = load_model(model_name)
    model_name = 'ssd_mobilenet_v1_coco_2017_11_17'
    detection_model = load_model(model_name)
    # show_inference(masking_model, image_path, new_image_path, params)
    show_inference(detection_model, image_path, new_image_path, params)


def show_inference(model, image_path, new_image_path, params):
  image = imread(image_path)
  # the array based representation of the image will be used later in order to prepare the
  # result image with boxes and labels on it.
  # List of the strings that is used to add correct label for each box.
  path, dirs, files = next(os.walk('/home/sergey/models/research/object_detection/data/'))
  PATH_TO_LABELS = path + 'mscoco_label_map.pbtxt'
  category_index = label_map_util.create_category_index_from_labelmap(PATH_TO_LABELS, use_display_name=True)
  image_np = np.array(image)
  # Actual detection.
  old_output_dict = run_inference_for_single_image(model, image_np)
  # Visualization of the results of a detection.
  output_dict = {'detection_classes': [], 'detection_scores': [], 'detection_boxes': [], 'num_detections': 0}
  wanted_objects = params['wanted_objects']
  for i in range(len(old_output_dict['detection_classes'])):
    if category_index[old_output_dict['detection_classes'][i]]['name'] in wanted_objects:
      output_dict['detection_classes'].append(old_output_dict['detection_classes'][i])
      output_dict['detection_scores'].append(old_output_dict['detection_scores'][i])
      output_dict['detection_boxes'].append(old_output_dict['detection_boxes'][i])
      output_dict['num_detections']+=1
  output_dict['detection_classes'] = np.array(output_dict['detection_classes'])
  output_dict['detection_boxes'] = np.array(output_dict['detection_boxes'])
  output_dict['detection_scores'] = np.array(output_dict['detection_scores'])
  vis_util.visualize_boxes_and_labels_on_image_array(
      image_np,
      output_dict['detection_boxes'],
      output_dict['detection_classes'],
      output_dict['detection_scores'],
      category_index,
      instance_masks=output_dict.get('detection_masks_reframed', None),
      use_normalized_coordinates=True,
      line_thickness=8)

  # display(Image.fromarray(image_np))
  save_image(image_np, new_image_path, "tensorflow")
  return image_np


def run_inference_for_single_image(model, img):
  image = img.copy()
  image = np.asarray(image)
  # The input needs to be a tensor, convert it using `tf.convert_to_tensor`.
  input_tensor = tf.convert_to_tensor(image)
  # The model expects a batch of images, so add an axis with `tf.newaxis`.
  input_tensor = input_tensor[tf.newaxis,...]

  # Run inference
  output_dict = model(input_tensor)

  # All outputs are batches tensors.
  # Convert to numpy arrays, and take index [0] to remove the batch dimension.
  # We're only interested in the first num_detections.
  num_detections = int(output_dict.pop('num_detections'))
  output_dict = {key:value[0, :num_detections].numpy()
                 for key,value in output_dict.items()}
  output_dict['num_detections'] = num_detections

  # detection_classes should be ints.
  output_dict['detection_classes'] = output_dict['detection_classes'].astype(np.int64)

  # Handle models with masks:
  if 'detection_masks' in output_dict:
    # Reframe the the bbox mask to the image size.
    detection_masks_reframed = utils_ops.reframe_box_masks_to_image_masks(
              output_dict['detection_masks'], output_dict['detection_boxes'],
               image.shape[0], image.shape[1])
    detection_masks_reframed = tf.cast(detection_masks_reframed > 0.5,
                                       tf.uint8)
    output_dict['detection_masks_reframed'] = detection_masks_reframed.numpy()

  return output_dict


# In[13]:


def run_all_algorithms(path_to_dir):
    PATH_TO_TEST_IMAGES_DIR = pathlib.Path(path_to_dir)
    TEST_IMAGE_PATHS = sorted(list(PATH_TO_TEST_IMAGES_DIR.glob("*.jpg")) +
                              list(PATH_TO_TEST_IMAGES_DIR.glob("*.jpeg")) +
                              list(PATH_TO_TEST_IMAGES_DIR.glob("*.png")))
    for image_path in TEST_IMAGE_PATHS:
        find_objects_by_edges(image_path)
        find_objects_viola_jones(image_path, str(path_to_dir).split("/")[-1])
        find_objects_tensorflow(image_path)


# In[14]:
parser=argparse.ArgumentParser()
parser.add_argument('--blur_strength',  type=int, default=9)
parser.add_argument('--canny_lower',  type=int, default=150)
parser.add_argument('--canny_upper',  type=int, default=150)
parser.add_argument('--hough_line_length', type=int, default=15)
parser.add_argument('--hough_line_treshold', type=int, default=20)
parser.add_argument('--hough_line_gap', type=int, default=5)
parser.add_argument('--hough_circle_min_dist', type=int, default=50)
parser.add_argument('--hough_circle_min_radius', type=int, default=10)
parser.add_argument('--hough_circle_max_radius', type=int, default=50)
parser.add_argument('--hough_circle_param1', type=int, default=500)
parser.add_argument('--hough_circle_param2', type=int, default=20)
parser.add_argument('--hough_mode', type=str, default="lines")
parser.add_argument('--hough_line_color', nargs='+', default=[255, 0, 255])
parser.add_argument('--image_path', help="Do image_path option", type=str)
parser.add_argument('--new_image_path', help="Do new_image_path option" ,type=str)
parser.add_argument('--method',  type=str, default="hough")
parser.add_argument('--object_type', type=str, default="cars")
parser.add_argument('--scale_factor', type=float, default=1.05)
parser.add_argument('--min_neighbors', type=int, default=1)
parser.add_argument('--wanted_objects', nargs='+', default=['car', 'airplane', 'cell phone', 'bicycle', 'motorcycle', 'train', 'bus', 'truck', 'boat', 'traffic light', 'laptop', 'mouse'])
args=parser.parse_args()

method =  args.method
os.environ['KMP_WARNINGS'] = '0'
if method == "hough":
  image_path = args.image_path
  new_image_path = args.new_image_path
  blur_strength = args.blur_strength
  canny_lower = args.canny_lower
  canny_upper = args.canny_upper
  hough_line_length = args.hough_line_length
  hough_line_treshold = args.hough_line_treshold
  hough_line_gap = args.hough_line_gap
  hough_circle_min_radius = args.hough_circle_min_radius
  hough_circle_max_radius = args.hough_circle_max_radius
  hough_circle_param1 = args.hough_circle_param1
  hough_circle_param2 = args.hough_circle_param2
  hough_circle_min_dist = args.hough_circle_min_dist
  hough_mode = args.hough_mode
  hough_line_color = args.hough_line_color
  params = {"hough_line_color": hough_line_color, "hough_mode": hough_mode,"hough_circle_min_dist": hough_circle_min_dist, "hough_circle_param2": hough_circle_param2,"hough_circle_param1": hough_circle_param1, "hough_circle_max_radius": hough_circle_max_radius, "hough_circle_min_radius": hough_circle_min_radius, "blur_strength": blur_strength, "canny_lower": canny_lower, "hough_line_gap": hough_line_gap, "hough_line_treshold": hough_line_treshold, "hough_line_length": hough_line_length, "canny_upper": canny_upper}
  find_objects_by_edges(image_path, new_image_path, params)
  print(new_image_path)
elif method == "haar":
  image_path = args.image_path
  new_image_path = args.new_image_path
  object_type = args.object_type
  scale_factor = args.scale_factor
  min_neighbors = args.min_neighbors
  params = {"object_type": object_type, "scale_factor": scale_factor, "min_neighbors": min_neighbors}
  find_objects_viola_jones(image_path, new_image_path, params)
  print(new_image_path)
elif method == "tensorflow":
  image_path = args.image_path
  new_image_path = args.new_image_path
  wanted_objects = args.wanted_objects
  params = {"wanted_objects": wanted_objects}
  find_objects_tensorflow(image_path, new_image_path, params)
  print(new_image_path)


# %%
