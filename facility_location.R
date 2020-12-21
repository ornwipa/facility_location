# generate data
set.seed(12345)
grid_size <- 1000

# locate customers in a grid with euclidean distances
n <- 100
customer_locations <- data.frame(
  id = 1:n,
  x = round(runif(n) * grid_size),
  y = round(runif(n) * grid_size)
) 

# place facilities (distribution centers or warehouses)
m <- 20
facility_locations <- data.frame(
  id = 1:m,
  x = round(runif(m) * grid_size),
  y = round(runif(m) * grid_size)
)

# set fixed cost of facilities, normally distributed
fixedcost <- round(rnorm(m, mean = grid_size * 10, sd = grid_size * 5))

# set transportation cost a function where customer and facility are parameters
transportcost <- function(i, j) {
  customer <- customer_locations[i,]
  facility <- facility_locations[j,]
  round(sqrt((customer$x - facility$x)^2 + (customer$y - facility$y)^2))
}

# plot data: black = customer, red = facility
library(ggplot2)
p <- ggplot(customer_locations, aes(x, y)) + geom_point() +
  geom_point(data = facility_locations, color = "red", alpha = 0.8, shape = 17) +
  scale_x_continuous(limits = c(0, grid_size)) +
  scale_y_continuous(limits = c(0, grid_size)) +
  theme(axis.title = element_blank(), 
        axis.ticks = element_blank(), 
        axis.text = element_blank(), panel.grid = element_blank())
p + ggtitle("Facility Location problem", 
            "Black dots are customers. Light red triangles show potential warehouse locations.")

# build a model with the `ompr` package:
library(ompr)
library(magrittr)
model <- MIPModel() %>%
  
  # the variable x_ij = 1 IFF customer i is served by facility j
  add_variable(x[i, j], i = 1:n, j = 1:m, type = "binary") %>%
  
  # the variable y_j = 1 IFF facility j is built/used
  add_variable(y[j], j = 1:m, type = "binary") %>%
  
  # objective function : minimize total cost = transportation cost + fixed cost
  set_objective(sum_expr(transportcost(i, j) * x[i, j], i = 1:n, j = 1:m) + 
                sum_expr(fixedcost[j] * y[j], j = 1:m), "min") %>%
  
  # constraint : all customers need to be served by (assigned to) a facility
  add_constraint(sum_expr(x[i, j], j = 1:m) == 1, i = 1:n) %>%
  
  # constraint : if a customer is assigned to a facility, then this facility is built
  add_constraint(x[i, j] <= y[j], i = 1:n, j = 1:m)

# solve the model with `glpk` package:
library(ompr.roi)
library(ROI.plugin.glpk)
result <- solve_model(model, with_ROI(solver = "glpk", verbose = TRUE))
matching <- result %>% get_solution(x[i,j]) %>% filter(value == 1) %>% select(i, j)
sum(fixedcost[unique(matching$j)]) # fixed cost

# show the chosen facility in the previous plot:
customer_count <- matching %>% group_by(j) %>% summarise(n = n()) %>% rename(id = j)
plot_facility <- facility_locations %>% mutate(costs = fixedcost) %>% 
  inner_join(customer_count, by = "id") %>% filter(id %in% unique(matching$j))

# add assignment to the previously plot:
plot_assignment <- matching %>% 
  inner_join(customer_locations, by = c("i" = "id")) %>% 
  inner_join(facility_locations, by = c("j" = "id"))

p + 
  geom_segment(data = plot_assignment, aes(x = x.y, y = y.y, xend = x.x, yend = y.x)) +
  geom_point(data = facility_locations, color = "red", size = 3, shape = 17) +
  ggrepel::geom_label_repel(data = plot_facility, aes(label = paste0("fixed costs: ", costs, 
                                                                     "; customers: ", n)),
                            size = 2, nudge_y = 20) +
  ggtitle(paste0("Optimal solution for facility location problem"),
          "Big red triangles show distribution centers that will be built, light red are unused locations. 
          Black dots represent customers served by the respective warehouses")
