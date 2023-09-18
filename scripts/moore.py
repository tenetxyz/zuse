class VoxelCoord:
    def __init__(self, x, y, z):
        self.x = x
        self.y = y
        self.z = z

    def __repr__(self):
        return f"VoxelCoord(x={self.x}, y={self.y}, z={self.z})"


def get_moore_neighbours(center_coord, neighbour_radius):
    # Calculate the number of neighbours using the corrected formula
    n = 2 * neighbour_radius + 1
    count = 6 * n ** 2 - 12 * n + 8

    # Create a list to store the neighbours
    neighbours = []

    # Loop through each dimension
    for i in range(-neighbour_radius, neighbour_radius + 1):
        for j in range(-neighbour_radius, neighbour_radius + 1):
            for k in range(-neighbour_radius, neighbour_radius + 1):

                # Ignore the center
                if i == 0 and j == 0 and k == 0:
                    continue

                # Ignore inner cube (radius less than neighbour_radius)
                if abs(i) < neighbour_radius and abs(j) < neighbour_radius and abs(k) < neighbour_radius:
                    continue

                # This coordinate belongs to the shell, so add it to the list
                neighbours.append(VoxelCoord(center_coord.x + i, center_coord.y + j, center_coord.z + k))

    return neighbours


# Example usage
center = VoxelCoord(0, 0, 0)
radius = 1
neighbours = get_moore_neighbours(center, radius)
print("Radius 1")
print(len(neighbours))
for neighbour in neighbours:
    print(neighbour)

radius = 2
neighbours = get_moore_neighbours(center, radius)
print("Radius 2")
print(len(neighbours))
for neighbour in neighbours:
    print(neighbour)
