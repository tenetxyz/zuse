"""
This script reads all PNG images from a specified input directory, processes each image to create a UV map,
and saves the generated UV map to a specified output directory.

Usage:
- Place your 16x16 PNG images in the input directory.
- Run the script: python to-uvwrap.py
- Your UV maps will be created in the output directory.
"""

import os
from PIL import Image

input_dir = 'in'
output_dir = 'out'

# Define the layout
layout = [
    [0, 1, 1, 0],
    [1, 1, 1, 1]
]

# Get all the files in the input directory
files = os.listdir(input_dir)

# Filter the list to include only .png files
images = [file for file in files if file.endswith('.png')]

# Loop through all the images
for image_file in images:
    # Create new empty image with dimensions 128x64
    uv_map = Image.new('RGBA', (64, 32), color=(0,0,0,0))  # Image with transparency

    # Load the image
    voxel_texture = Image.open(os.path.join(input_dir, image_file))

    # Loop through the layout
    for row in range(2):
        for column in range(4):
            if layout[row][column] == 1:  # If the layout cell is marked with 1, place the image
                uv_map.paste(voxel_texture, (column*16, row*16))
                
    # Save the UV map to a PNG file in the output directory
    uv_map.save(os.path.join(output_dir, image_file))

print('UV maps created successfully!')

