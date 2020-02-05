
#!/bin/bash

# sh CarlaUE4.sh /Game/Maps/Town01 -windowed -world-port=2000  -benchmark -fps=10
# python collect.py --data-path /home/whizz/Desktop/coil-datasets/Carla100 --data-configuration-name coil_training_dataset
# docker run -p 2000-2002:2000-2002 --runtime=nvidia -e NVIDIA_VISIBLE_DEVICES=0 carlasim/carla:0.8.4
# docker run -p 2000-2002:2000-2002 --runtime=nvidia -e NVIDIA_VISIBLE_DEVICES=0 carlasim/carla:0.8.4 /bin/bash CarlaUE4.sh  < Your list of parameters >


export PYTHONPATH=$PYTHONPATH:/home/whizz/Desktop/coiltraine
export COIL_DATASET_PATH="/home/whizz/Desktop/coil-datasets"
echo "COIL_DATASET_PATH used: $COIL_DATASET_PATH"

# Baseline: 10.62433333333333  hours of data

# Carla100 is trained on weathers 1,3,6,8
# Validation and dataset used in papers uses
#   Town01, weather 1, 2hours
#   Town02, weather 8, 2hours



# FOR DEBUGGING

# python /home/whizz/Desktop/data-collector/collect_iterative.py \
#     --number-episodes=17 \
#     --data-configuration-name='coil_training_dataset' \
#     --data-path='/home/whizz/Desktop/coil-datasets/Carla100_test' \
#     --verbose


# ITERATIVE VERSION
python /home/whizz/Desktop/data-collector/multi_gpu_collection_iterative.py \
    --number_collectors=4 \
    --number_episodes=70 \
    --carlas_per_gpu=4 \
    --start_episode=0 \
    --data-configuration-name='coil_training_dataset_crop' \
    --data-path='/home/whizz/Desktop/coil-datasets/Carla100_iterative_cropped' \
    --container-name='carlagear' \
    --town_name='1' \
    --overwrite_weather='1,3,6,8'
#    --csv_file='/home/whizz/Desktop/coil-datasets/Carla100_iterative/collated_metadata.csv'



# NON ITERATIVE VERSIONS FOR VALIDATION
# python /home/whizz/Desktop/data-collector/multi_gpu_collection.py \
#     --number_collectors=1 \
#     --number_episodes=13 \
#     --carlas_per_gpu=1 \
#     --start_episode=103 \
#     --data-configuration-name='coil_training_dataset_crop' \
#     --data-path='/home/whizz/Desktop/coil-datasets/Carla100_Val1_noise' \
#     --container-name='carlagear' \
#     --town_name='1' \
#     --overwrite_weather='1' \
#     --overwrite_noise_perc=100.0

# python /home/whizz/Desktop/data-collector/multi_gpu_collection_randompose.py \
#     --number_collectors=4 \
#     --number_episodes=4 \
#     --carlas_per_gpu=4 \
#     --start_episode=200 \
#     --data-configuration-name='coil_training_dataset_crop' \
#     --data-path='/home/whizz/Desktop/coil-datasets/Carla100_Val2_noise' \
#     --container-name='carlagear' \
#     --town_name='2' \
#     --overwrite_weather='14' \
#    --overwrite_noise_perc=100.0


# COLLATE EPISODE METADATA INTO CSV
python /home/whizz/Desktop/data-collector/tools/collate_metadata.py \
    --dataset_path="/home/whizz/Desktop/coil-datasets/Carla100_iterative"



# FOLDER RENAMING
#becareful when handling folders!, exclude if required
# import os
# import re
# import glob
# import json
# jsons = [ file for file in glob.glob('**/metadata.json') ]
# new_jsons = []
# for j in jsons:
#     if j[8]=='0':
#         new_jsons.append(j)
# jsons = new_jsons
# POSITIONS = [ [29, 105], [130, 27], [87, 102], [27, 132], [44, 24],
#               [26, 96], [67, 34], [1, 28], [134, 140], [9, 105],
#               [129, 148], [16, 65], [16, 21], [97, 147], [51, 42],
#               [41, 30], [107, 16], [47, 69], [95, 102], [145, 16],
#               [64, 111], [47, 79], [69, 84], [31, 73], [81, 37],
#               [57, 35], [116, 42], [47, 75], [143, 132], [8, 145],
#               [107, 43], [111, 61], [105, 137], [72, 24], [77, 0],
#               [80, 17], [32, 12], [64, 3], [32, 146], [40, 33],
#               [127, 71], [116, 21], [49, 51], [110, 35], [85, 91],
#               [114, 93], [30, 7], [110, 133], [60, 43], [11, 98], [96, 49], [90, 85],
#               [27, 40], [37, 74], [97, 41], [110, 62], [19, 2], [138, 114], [131, 76],
#               [116, 95], [50, 71], [15, 97], [74, 71], [50, 133],
#               [23, 116], [38, 116], [101, 52], [5, 108], [23, 79], [13, 68]
#              ]
# for json_file in jsons:
#     with open(json_file, 'r') as file:
#         pose = json.loads(file.read())['pose']
#     pose = pose.replace('[','').replace(']','').split(',')
#     pose = [ int(i) for i in pose ]
#     ind = int(re.findall(r'\d+', json_file)[0])%1000
#     correct_ind = ind//70*70 + POSITIONS.index(pose) + 10000
#     if not os.path.exists( 'episode_%05d' %correct_ind ):
#         os.rename( os.path.dirname(json_file), 'episode_%05d' %correct_ind )
#     else:
#         print('bleah')