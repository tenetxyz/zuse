import matplotlib.pyplot as plt
import numpy as np
import noise

def generate_perlin_noise_3d(shape, res):
    def f(i, j, k):
        return noise.snoise3(i/res[0], j/res[1], k/res[2], octaves=4, persistence=0.5)
    return np.fromfunction(np.vectorize(f), shape, dtype=int)

def visualize_data(data, title):
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    x, y, z = data.nonzero()
    ax.scatter(x, y, z, alpha=0.6, edgecolors='none', s=20)
    ax.set_title(title)
    plt.show()

# Generate data
shape = (100, 100, 100)
res = (10, 10, 10)
mass_distribution = generate_perlin_noise_3d(shape, res)
energy_distribution = generate_perlin_noise_3d(shape, res)

# Thresholding the data for visualization
mass_threshold = np.percentile(mass_distribution, 90)  # Adjust threshold level as needed
energy_threshold = np.percentile(energy_distribution, 90)  # Adjust threshold level as needed

mass_distribution = (mass_distribution > mass_threshold) * 1
energy_distribution = (energy_distribution > energy_threshold) * 1

# Visualize data
visualize_data(mass_distribution, "Mass Distribution")
visualize_data(energy_distribution, "Energy Distribution")
