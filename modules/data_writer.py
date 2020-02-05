import os
import json
import shutil

from google.protobuf.json_format import MessageToJson, MessageToDict
from PIL import Image as PImage

def write_image_data(data, filename, format,
                    top_crop, bottom_crop, resize_width, resize_height):

    image = PImage.frombytes(mode='RGBA',
        size=(data.width, data.height),
        data=data.raw_data,
        decoder_name='raw')
    color = image.split()
    image = PImage.merge("RGB", color[2::-1])
    width, height = image.size
    
    if not (width == resize_width and height == resize_height):
        image = image.crop( (0, top_crop, width, height - bottom_crop) )
        image = image.resize( (resize_width, resize_height) )

    if not filename.endswith(format):
        filename += format
    
    folder = os.path.dirname(filename)
    if not os.path.isdir(folder):
        os.makedirs(folder)
    image.save(filename, quality=100)


def write_lidar_data(data, filename, format):

    if not filename.endswith(format):
        filename += format

    point_cloud = data.point_cloud

    def construct_ply_header():
        """Generates a PLY header given a total number of 3D points and
        coloring property if specified
        """
        points = len(point_cloud)  # Total point number
        header = ['ply',
                    'format ascii 1.0',
                    'element vertex {}',
                    'property float32 x',
                    'property float32 y',
                    'property float32 z',
                    'property uchar diffuse_red',
                    'property uchar diffuse_green',
                    'property uchar diffuse_blue',
                    'end_header']
        if not point_cloud._has_colors:
            return '\n'.join(header[0:6] + [header[-1]]).format(points)
        return '\n'.join(header).format(points)

    if not point_cloud._has_colors:
        ply = '\n'.join(['{:.2f} {:.2f} {:.2f}'.format(
            *p) for p in point_cloud._array.tolist()])
    else:
        points_3d = numpy.concatenate(
            (point_cloud._array, point_cloud._color_array), axis=1)
        ply = '\n'.join(['{:.2f} {:.2f} {:.2f} {:.0f} {:.0f} {:.0f}'
                            .format(*p) for p in points_3d.tolist()])

    # Create folder to save if does not exist.
    folder = os.path.dirname(filename)
    if not os.path.isdir(folder):
        os.makedirs(folder)

    # Open the file and save with the specific PLY format.
    with open(filename, 'w+') as ply_file:
        ply_file.write('\n'.join([construct_ply_header(), ply]))


def write_json_measurements(episode_path, data_point_id, measurements, control, control_noise,
                            state):

    with open(os.path.join(episode_path, 'measurements_' + data_point_id.zfill(5) + '.json'), 'w') as fo:

        jsonObj = MessageToDict(measurements)
        jsonObj.update(state)
        jsonObj.update({'steer': control.steer})
        jsonObj.update({'throttle': control.throttle})
        jsonObj.update({'brake': control.brake})
        jsonObj.update({'hand_brake': control.hand_brake})
        jsonObj.update({'reverse': control.reverse})
        jsonObj.update({'steer_noise': control_noise.steer})
        jsonObj.update({'throttle_noise': control_noise.throttle})
        jsonObj.update({'brake_noise': control_noise.brake})

        fo.write(json.dumps(jsonObj, sort_keys=True, indent=4))


def write_sensor_data(episode_path, data_point_id, sensor_data, sensors_frequency,
                      top_crop, bottom_crop, resize_width, resize_height):
    # try:
    #     from PIL import Image as PImage
    # except ImportError:
    #     raise RuntimeError(
    #         'cannot import PIL, make sure pillow package is installed')

    for name, data in sensor_data.items():
        if int(data_point_id) % int((1/sensors_frequency[name])) == 0:
            filename = os.path.join(episode_path, name + '_' + data_point_id.zfill(5))
            if 'Lidar' in name:
                format = '.ply'
                write_lidar_data(data, filename, format)
            else:
                format = '.png'
                write_image_data(data, filename, format,
                                top_crop, bottom_crop, resize_width, resize_height)
            
            # data.save_to_disk(os.path.join(episode_path, name + '_' + data_point_id.zfill(5)), format)


def make_dataset_path(dataset_path):
    if not os.path.exists(dataset_path):
        os.makedirs(dataset_path)


def add_metadata(dataset_path, settings_module):
    with open(os.path.join(dataset_path, 'metadata.json'), 'w') as fo:
        jsonObj = {}
        jsonObj.update(settings_module.sensors_yaw)
        jsonObj.update({'fov': settings_module.FOV})
        jsonObj.update({'width': settings_module.WINDOW_WIDTH})
        jsonObj.update({'height': settings_module.WINDOW_HEIGHT})
        jsonObj.update({'lateral_noise_percentage': settings_module.lat_noise_percent})
        jsonObj.update({'longitudinal_noise_percentage': settings_module.long_noise_percent})
        jsonObj.update({'car range': settings_module.NumberOfVehicles})
        jsonObj.update({'pedestrian range': settings_module.NumberOfPedestrians})
        jsonObj.update({'set_of_weathers': settings_module.set_of_weathers})
        fo.write(json.dumps(jsonObj, sort_keys=True, indent=4))

def add_episode_metadata(dataset_path, episode_number, episode_aspects):

    if not os.path.exists(os.path.join(dataset_path, 'episode_' + episode_number)):
        os.mkdir(os.path.join(dataset_path, 'episode_' + episode_number))

    with open(os.path.join(dataset_path, 'episode_' + episode_number, 'metadata.json'), 'w') as fo:

        jsonObj = {}
        jsonObj.update({'town_name': episode_aspects['town_name']})
        jsonObj.update({'number_of_pedestrian': episode_aspects['number_of_pedestrians']})
        jsonObj.update({'number_of_vehicles': episode_aspects['number_of_vehicles']})
        jsonObj.update({'seeds_pedestrians': episode_aspects['seeds_pedestrians']})
        jsonObj.update({'seeds_vehicles': episode_aspects['seeds_vehicles']})
        jsonObj.update({'weather': episode_aspects['weather']})
        
        poses_str = str(episode_aspects['pose']) 
        start_transform_str = str(episode_aspects['player_start_transform']).replace('\n', '')
        target_transform_str = str(episode_aspects['player_target_transform']).replace('\n', '')
        
        jsonObj.update({'pose': poses_str })
        jsonObj.update({'player_start_transform': start_transform_str })
        jsonObj.update({'player_target_transform': target_transform_str })
        fo.write(json.dumps(jsonObj, sort_keys=True, indent=4))



def add_data_point(measurements, control, control_noise, sensor_data, state,
                   dataset_path, episode_number, data_point_id, sensors_frequency,
                   top_crop, bottom_crop, resize_width, resize_height):

    episode_path = os.path.join(dataset_path, 'episode_' + episode_number)
    if not os.path.exists(os.path.join(dataset_path, 'episode_' + episode_number)):
        os.mkdir(os.path.join(dataset_path, 'episode_' + episode_number))
    write_sensor_data(episode_path, data_point_id, sensor_data, sensors_frequency,
                      top_crop, bottom_crop, resize_width, resize_height)
    write_json_measurements(episode_path, data_point_id, measurements, control, control_noise,
                            state)

# Delete an episode in the case
def delete_episode(dataset_path, episode_number):

    shutil.rmtree(os.path.join(dataset_path, 'episode_' + episode_number))