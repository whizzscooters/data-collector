
import os
import glob
import json
import argparse


def collate(dataset_path):
    """ Reads through all metadata in episodes, collates in csv
    
    Args:
        dataset_path   path    path to folder containing dataset's episodes
    
    Saves:
        csv file at dataset_path location, containing collated metadata
    """

    metadata_paths = glob.glob( os.path.join(dataset_path, '**/metadata.json') )
    
    output_csv_path = os.path.join(dataset_path, 'collated_metadata.csv')
    output_csv = open(output_csv_path, 'a')
    written_heading = False

    for metadata in metadata_paths:
        
        with open(metadata) as f:
            data = json.loads( f.read() )
        
        # write headers
        if not written_heading:
            
            heading = ','.join( data.keys() )
            output_csv.write( heading+'\n' )

            written_heading = True
        
        # write values
        values = [str(i) for i in data.values()]
        values = ','.join(values)
        output_csv.write( values+'\n' )

    output_csv.close()
    

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    
    parser.add_argument(
        "-d", "--dataset_path",
        help="path to dataset"
    )

    args = parser.parse_args()

    collate(args.dataset_path)