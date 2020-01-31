
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
# python /home/whizz/Desktop/data-collector/multi_gpu_collection_iterative.py \
#     --number_collectors=4 \
#     --number_episodes=70 \
#     --carlas_per_gpu=4 \
#     --start_episode=1000 \
#     --data-configuration-name='coil_training_dataset' \
#     --data-path='/home/whizz/Desktop/coil-datasets/Carla100_iterative' \
#     --container-name='carlagear' \
#     --town_name='1' \
#     --overwrite_weather='1,3,6,8' \
#     --csv_file='/home/whizz/Desktop/coil-datasets/Carla100_iterative/collated_metadata.csv'



# NON ITERATIVE VERSIONS
# python /home/whizz/Desktop/data-collector/multi_gpu_collection.py \
#     --number_collectors=1 \
#     --number_episodes=12 \
#     --carlas_per_gpu=1 \
#     --start_episode=104 \
#     --data-configuration-name='coil_training_dataset' \
#     --data-path='/home/whizz/Desktop/coil-datasets/Carla100_Val1_CorrectWeather' \
#     --container-name='carlagear' \
#     --town_name='1' \
#     --overwrite_weather='1'

# python /home/whizz/Desktop/data-collector/multi_gpu_collection_randompose.py \
#     --number_collectors=1 \
#     --number_episodes=6 \
#     --carlas_per_gpu=1 \
#     --start_episode=210 \
#     --data-configuration-name='coil_training_dataset' \
#     --data-path='/home/whizz/Desktop/coil-datasets/Carla100_Val2_CorrectWeather' \
#     --container-name='carlagear' \
#     --town_name='2' \
#     --overwrite_weather='8'


# COLLATE EPISODE METADATA INTO CSV
python /home/whizz/Desktop/data-collector/tools/collate_metadata.py \
    --dataset_path="/home/whizz/Desktop/coil-datasets/Carla100_Val1_CorrectWeather"