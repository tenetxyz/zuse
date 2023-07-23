def calculate_child_coords(parent_coords, scale):
    child_coords = []
    for dz in range(scale):
        for dy in range(scale):
            for dx in range(scale):
                child_coords.append(
                    (parent_coords[0] * scale + dx,
                     parent_coords[1] * scale + dy,
                     parent_coords[2] * scale + dz)
                )
    return child_coords

def calculate_parent_coords(child_coord, scale):
    parent_coord = (
        child_coord[0] // scale,
        child_coord[1] // scale,
        child_coord[2] // scale
    )
    return parent_coord

base_coords = calculate_child_coords([0, 0, 0], 2)
for coord in base_coords:
    print(coord)
    child_coords = calculate_child_coords(coord, 2)
    print(child_coords)
    for child_coord in child_coords:
        print(calculate_parent_coords(child_coord, 2))
    print("-"*12)

print(calculate_child_coords([20, 102, 3900], 2))
print(calculate_parent_coords([41, 205, 7800], 2))

print(calculate_child_coords([-20, 102, -3900], 2))
print(calculate_parent_coords([-39, 205, -7800], 2))

print(calculate_child_coords([-20, -102, -3900], 2))
print(calculate_parent_coords([-39, -203, -7800], 2))