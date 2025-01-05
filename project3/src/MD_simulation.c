#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// This block of lines is used to read in the number of atoms and handle some errors regarding the file.

size_t read_Natoms(FILE* input_file) {
    if (input_file == NULL) {
        fprintf(stderr, "Error: File pointer is NULL.\n");
        return 0;
    }

    size_t num_atoms;
    if (fscanf(input_file, "%zu", &num_atoms) != 1) {
        fprintf(stderr, "Error: Could not read the number of atoms from the file.\n");
        return 0;
    }

    if ((long)num_atoms < 0) { // Cast to long for negative check
        fprintf(stderr, "Error: The number of atoms cannot be negative.\n");
        return 0;
    }

    return num_atoms;
}

// This block of lines is used to read the coordinates, mass and store them

void read_molecule(FILE* input_file, size_t Natoms, double** coord, double* mass) {
    for (size_t i = 0; i < Natoms; i++) {
        if (fscanf(input_file, "%lf %lf %lf %lf", &coord[i][0], &coord[i][1], &coord[i][2], &mass[i]) != 4) {
            fprintf(stderr, "Error: Could not read coordinates and mass for atom %zu.\n", i + 1);
            exit(EXIT_FAILURE);
        }
    }
}

// This block of lines is used to calculate the distances between atoms.

void compute_distances(size_t Natoms, double** coord, double** distance) {
    for (size_t i = 0; i < Natoms; i++) {
        for (size_t j = i + 1; j < Natoms; j++) { // Start from i + 1 to skip redundant calculations
            double dx = coord[i][0] - coord[j][0];
            double dy = coord[i][1] - coord[j][1];
            double dz = coord[i][2] - coord[j][2];
            distance[i][j] = distance[j][i] = sqrt(dx * dx + dy * dy + dz * dz);
        }
    }
}

// This block of lines is used to calculate the potential energy.

double V(double epsilon, double sigma, size_t Natoms, double** distance) {
    double total_energy = 0.0;
    for (size_t i = 0; i < Natoms; i++) {
        for (size_t j = i + 1; j < Natoms; j++) {
            double r = distance[i][j];
            if (r > 0) { // Avoid division by zero
                double term = pow(sigma / r, 6);
                total_energy += 4 * epsilon * (term * term - term);
            }
        }
    }
    return total_energy;
}

// This block of lines is used to calculate the kinetic energy.

double T(size_t Natoms, double** velocity, double* mass) {
    double total_kinetic_energy = 0.0;
    for (size_t i = 0; i < Natoms; i++) {
        double v_squared = velocity[i][0] * velocity[i][0] + velocity[i][1] * velocity[i][1] + velocity[i][2] * velocity[i][2];
        total_kinetic_energy += 0.5 * mass[i] * v_squared;
    }
    return total_kinetic_energy;
}

// This block of lines is used to calculate the total energy.

double E(double T, double V) {
    return T + V;
}

// This computes the analytical expression of the acceleration.

void compute_acc(size_t Natoms, double** coord, double* mass, double** distance, double** acceleration) {
    double epsilon = 0.0661; // Lennard-Jones parameter
    double sigma = 0.3345;   // Lennard-Jones parameter

    for (size_t i = 0; i < Natoms; i++) {
        acceleration[i][0] = 0.0;
        acceleration[i][1] = 0.0;
        acceleration[i][2] = 0.0;

        for (size_t j = 0; j < Natoms; j++) {
            if (i != j) {
                double r = distance[i][j];
                if (r > 0) { // Avoid division by zero
                    double U = 24 * (epsilon / r) * (pow(sigma / r, 6) - 2 * pow(sigma / r, 12));
                    acceleration[i][0] += U * (coord[i][0] - coord[j][0]) / r;
                    acceleration[i][1] += U * (coord[i][1] - coord[j][1]) / r;
                    acceleration[i][2] += U * (coord[i][2] - coord[j][2]) / r;
                }
            }
        }

        acceleration[i][0] *= -1.0 / mass[i];
        acceleration[i][1] *= -1.0 / mass[i];
        acceleration[i][2] *= -1.0 / mass[i];
    }
}

// This uses the Verlet Algorithm to make the dynamic.

void molecular_dynamics_verlet(size_t Natoms, double** coord, double** velocity, double* mass, double** distance, double** acceleration, double time_step, size_t num_steps) {
    FILE* output_file = fopen("trajectory.xyz", "w");
    if (output_file == NULL) {
        fprintf(stderr, "Error: Could not open output file for writing.\n");
        exit(EXIT_FAILURE);

    }

    // Compute initial accelerations
    compute_acc(Natoms, coord, mass, distance, acceleration);

    for (size_t step = 0; step < num_steps; step++) {
        // Update positions using r(n+1) = r(n) + v(n) * dt + a(n) * (dt^2 / 2)
        for (size_t i = 0; i < Natoms; i++) {
            for (size_t j = 0; j < 3; j++) {
                coord[i][j] += velocity[i][j] * time_step + 0.5 * acceleration[i][j] * time_step * time_step;
            }
        }

        // Compute distances based on updated positions
        compute_distances(Natoms, coord, distance);

        // Store old accelerations
        double** old_acceleration = malloc(Natoms * sizeof(double*));
        for (size_t i = 0; i < Natoms; i++) {
            old_acceleration[i] = malloc(3 * sizeof(double));
            for (size_t j = 0; j < 3; j++) {
                old_acceleration[i][j] = acceleration[i][j];
            }
        }

        // Compute new accelerations based on updated positions
        compute_acc(Natoms, coord, mass, distance, acceleration);

        // Update velocities using v(n+1) = v(n) + 0.5 * (a(n) + a(n+1)) * dt
        for (size_t i = 0; i < Natoms; i++) {
            for (size_t j = 0; j < 3; j++) {
                velocity[i][j] += 0.5 * (old_acceleration[i][j] + acceleration[i][j]) * time_step;
            }
        }

        // Free old accelerations
        for (size_t i = 0; i < Natoms; i++) {
            free(old_acceleration[i]);
        }
        free(old_acceleration);

        // Compute energies
        double potential_energy = V(0.0661, 0.3345, Natoms, distance);
        double kinetic_energy = T(Natoms, velocity, mass);
        double total_energy = E(kinetic_energy, potential_energy);

        // Write to file every 10 steps
        if (step % 10 == 0) {
            fprintf(output_file, "%zu\n", Natoms);
            fprintf(output_file, "Kinetic Energy: %.6lf, Potential Energy: %.6lf, Total Energy: %.6lf\n", kinetic_energy, potential_energy, total_energy);
            for (size_t i = 0; i < Natoms; i++) {
                fprintf(output_file, "Atom%zu %.6lf %.6lf %.6lf\n", i + 1, coord[i][0], coord[i][1], coord[i][2]);
            }
        }

        // Print step information (optional)
        printf("Step %zu:\n", step + 1);
        for (size_t i = 0; i < Natoms; i++) {
            printf("Atom %zu: Position (%.6lf, %.6lf, %.6lf), Velocity (%.6lf, %.6lf, %.6lf)\n",
                   i + 1, coord[i][0], coord[i][1], coord[i][2], velocity[i][0], velocity[i][1], velocity[i][2]);
        }
    }

    fclose(output_file);

}

// This provide the outputs and uses the previous functions.

int main(int argc, char* argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <file_path>\n", argv[0]);
        return EXIT_FAILURE;
    }

    FILE* input_file = fopen(argv[1], "r");
    if (input_file == NULL) {
        perror("Error opening file");
        return EXIT_FAILURE;
    }

    size_t num_atoms = read_Natoms(input_file);
    if (num_atoms == 0) {
        fclose(input_file);
        return EXIT_FAILURE;
    }

    printf("Number of atoms: %zu\n", num_atoms);

    double** coord = malloc(num_atoms * sizeof(double*));
    for (size_t i = 0; i < num_atoms; i++) {
        coord[i] = malloc(3 * sizeof(double));
    }
    double* mass = malloc(num_atoms * sizeof(double));
    double** distance = malloc(num_atoms * sizeof(double*));
    for (size_t i = 0; i < num_atoms; i++) {
        distance[i] = malloc(num_atoms * sizeof(double));
    }
    double** velocity = malloc(num_atoms * sizeof(double*));
    for (size_t i = 0; i < num_atoms; i++) {
        velocity[i] = malloc(3 * sizeof(double));
        for (size_t j = 0; j < 3; j++) {
            velocity[i][j] = 0.0; // Initialize velocities to zero
        }
    }
    double** acceleration = malloc(num_atoms * sizeof(double*));
    for (size_t i = 0; i < num_atoms; i++) {
        acceleration[i] = malloc(3 * sizeof(double));
    }

    if (coord == NULL || mass == NULL || distance == NULL || velocity == NULL || acceleration == NULL) {
        fprintf(stderr, "Error: Memory allocation failed.\n");
        for (size_t i = 0; i < num_atoms; i++) {
            free(coord[i]);
            free(distance[i]);
            free(velocity[i]);
            free(acceleration[i]);
        }
        free(coord);
        free(distance);
        free(velocity);
        free(acceleration);
        fclose(input_file);
        return EXIT_FAILURE;
    }

    read_molecule(input_file, num_atoms, coord, mass);

    compute_distances(num_atoms, coord, distance);

    printf("Coordinates and masses:\n");
    for (size_t i = 0; i < num_atoms; i++) {
        printf("Atom %zu: (%.3lf, %.3lf, %.3lf), Mass: %.3lf\n", i + 1, coord[i][0], coord[i][1], coord[i][2], mass[i]);
    }

    printf("Internuclear distances:\n");
    for (size_t i = 0; i < num_atoms; i++) {
        for (size_t j = i + 1; j < num_atoms; j++) { // Print only non-redundant distances
            printf("Distance[%zu][%zu]: %.3lf\n", i + 1, j + 1, distance[i][j]);
        }
    }

    double epsilon = 0.0661; // Value for epsilon
    double sigma = 0.3345;   // Value for sigma
    double potential_energy = V(epsilon, sigma, num_atoms, distance);
    printf("Total potential energy: %.6lf\n", potential_energy);

    double kinetic_energy = T(num_atoms, velocity, mass);
    printf("Total kinetic energy: %.6lf\n", kinetic_energy);

    double total_energy = E(kinetic_energy, potential_energy);
    printf("Total energy of the system: %.6lf\n", total_energy);

    compute_acc(num_atoms, coord, mass, distance, acceleration);

    printf("Accelerations:\n");
    for (size_t i = 0; i < num_atoms; i++) {
        printf("Atom %zu: ax = %.6lf, ay = %.6lf, az = %.6lf\n", i + 1, acceleration[i][0], acceleration[i][1], acceleration[i][2]);
    }


    double time_step = 0.2;
    size_t num_steps = 1000;
    molecular_dynamics_verlet(num_atoms, coord, velocity, mass, distance, acceleration, time_step, num_steps);

    for (size_t i = 0; i < num_atoms; i++) {
        free(coord[i]);
        free(distance[i]);
        free(velocity[i]);
        free(acceleration[i]);
    }
    free(coord);
    free(distance);
    free(velocity);
    free(acceleration);
    free(mass);
    fclose(input_file);
    return EXIT_SUCCESS;
}
