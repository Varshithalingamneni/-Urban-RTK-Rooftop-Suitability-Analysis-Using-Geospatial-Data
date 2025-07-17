library(DBI)
library(RPostgres)
library(tidyr)
library(plotly)

# 1) Connect to Postgres
con <- dbConnect(
  Postgres(),
  dbname   = "buildings_db",
  host     = "localhost",
  port     = 5432,
  user     = "postgres",
  password = "Sinister@001"
)

# 2) Grab *all* eligible building IDs
eligible <- dbGetQuery(con, "SELECT building_id FROM eligible_candidates")$building_id

# 3) Decide on a fixed blocking‐angle ceiling (°)
#    since your threshold is 10°, we'll cap all plots at [0,10]
zmax <- 10

# 4) Function to build and show one plot, all on same z‐range
plot_one <- function(bldg) {
  prof <- dbGetQuery(con, sprintf(
    "SELECT studied_horiz_azimuth_degree AS azimuth, blocking_angle
     FROM blocking_angle_data
     WHERE studied_blgd_id = '%s'
     ORDER BY studied_horiz_azimuth_degree", 
    bldg
  )) %>%
    complete(azimuth = 0:359, fill = list(blocking_angle = 0))
  
  theta <- prof$azimuth * pi/180
  r     <- prof$blocking_angle
  x_end <- cos(theta);  y_end <- sin(theta)
  
  # Build vertical bars from z=0 up to z=r
  xs <- as.vector(rbind(x_end, x_end, NA))
  ys <- as.vector(rbind(y_end, y_end, NA))
  zs <- as.vector(rbind(0,     r,     NA))
  
  hover_text <- paste0("Azimuth: ", prof$azimuth, "°<br>",
                       "Blocking: ", sprintf("%.2f", r), "°")
  hover_text <- rep(hover_text, each=3)
  hover_text[seq(3, length(hover_text), 3)] <- NA
  
  # Center spokes at z=0
  x_center <- as.vector(rbind(rep(0,360), x_end, NA))
  y_center <- as.vector(rbind(rep(0,360), y_end, NA))
  z_center <- rep(0, length(x_center))
  
  plot_ly(type="scatter3d", mode="lines") %>%
    # vertical bars
    add_trace(
      x = xs, y = ys, z = zs,
      text = hover_text, hoverinfo="text",
      line = list(
        color = rep(r, each=3),
        colorscale = "Viridis",
        cmin = 0, cmax = zmax,
        width = 6
      ),
      name = "Blocking"
    ) %>%
    # center spokes
    add_trace(
      x = x_center, y = y_center, z = z_center,
      line = list(color="gray", width=1),
      showlegend=FALSE, hoverinfo="skip"
    ) %>%
    layout(
      title = paste("3D Polar Profile —", bldg),
      scene = list(
        xaxis = list(showticklabels=FALSE, zeroline=FALSE),
        yaxis = list(showticklabels=FALSE, zeroline=FALSE),
        zaxis = list(title = "Blocking Angle (°)",
                     range = c(0, zmax))
      ),
      margin = list(l=0,r=0,b=0,t=40)
    ) %>%
    print()
}

# 5) Loop through every eligible building
for(b in eligible) {
  plot_one(b)
}

dbDisconnect(con)
