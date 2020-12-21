# Facility Location Problem

According to the Northwestern University Process Optimization Open Textbook:
> Facility location problems seek to optimize the placement of facilities such that the demands of consumers can be met at the lowest cost and/or shortest distance. 

Given a set of customers and set of locations to build distribution centers (i.e., warehouses), the task here is to decide where to build distribution centers, and from which distribution goods will be shipped to which customers.

There are fixed costs associated with the building of each distribution center as well as transportation costs from a certain distribution center to a certain customer.

In this case, there is no capacity limit for each distribution; that is, uncapacitated facility location problem.

## Requirement

**R Optimization Infrastructure** --> [more information](https://roi.r-forge.r-project.org/index.html)

It is important to note that:
> [ROI.plugin.glpk](https://cran.r-project.org/web/packages/ROI.plugin.glpk/index.html) itself doesn’t contain compiled code but it imports Rglpk. The [Rglpk](https://cran.r-project.org/web/packages/Rglpk/index.html) package requires the linear programming kit - development files to be installed before the installation of Rglpk. Depending on the distribution, the linear programming kit - development files may be installed via one of the following commands.

To use the library, run the following command to install the packages.
```
sudo apt-get install liglpk-dev
sudo apt-get install r-cran-rglpk
```

Note that, the above commands are for the installation in Debian-based distributions. See the [instructions](https://roi.r-forge.r-project.org/installation.html) for other distributions or operating systems.

## Results

Visualization of the selected facility location and the assignment of facilities to customers:
![result](https://github.com/ornwipa/facility_location/blob/main/result.png)

## Acknowledgement

Thank to the guideline in [R for Operations Research](https://www.r-orms.org/) for parts of the codes and analyses.
