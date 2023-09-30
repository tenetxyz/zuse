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
    x, y, z = np.indices(data.shape)
    colors = data.flatten()  # Convert data to 1D array for coloring
    colors = plt.cm.viridis(colors / colors.max())  # Normalize and apply color map
    ax.scatter(x.flatten(), y.flatten(), z.flatten(), c=colors, alpha=0.6, edgecolors='none', s=20)
    ax.set_title(title)
    plt.show()

# Generate data
shape = (100, 100, 100)
res = (10, 10, 10)
mass_distribution = generate_perlin_noise_3d(shape, res)
energy_distribution = generate_perlin_noise_3d(shape, res)

# Visualize data
visualize_data(mass_distribution, "Mass Distribution")
visualize_data(energy_distribution, "Energy Distribution")

