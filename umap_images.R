library(crosstalk)
library(plotly)
library(DT)

# use the umap package in python on the featurematrix that we just calculated
library(reticulate)
reticulate::use_python('/usr/bin/python')

## remove the vgg_notop object, for some reason it points to 
## conda r-tensorflow env where there is no umap module

umap = reticulate::import("umap")

embedding = umap$UMAP(
  n_neighbors = 5L,
  n_components = 3L,
  min_dist = 0.25,
  metric='euclidean'
)

## compute UMAP with 3 components\
featurematix <- load('featurematrix.Rdata')
embedding_out = embedding$fit_transform(featurematrix)

## create data for plotly plot
folder = "/Users/rogersmeets/testpics/"
allimages = paste0(folder, dir(folder))

plotdata = data.frame(round(embedding_out,2))
plotdata$image = paste0(
  "<img src='",
  allimages, "'",
  " height='600' width='800'>")

### create linkable plotly and image with crosstalk 
sd <- SharedData$new(plotdata)

p <- plot_ly(
  sd, x = ~X1, y = ~X2,z = ~X3,
  width	= 800,
  height = 600
  ) %>% 
  add_markers(alpha = 0.85) %>%
  highlight("plotly_hover", dynamic = TRUE)

tbl = DT::datatable(
  sd, 
  escape = FALSE,  
  options = list(
    dom = 't',
    pageLength = 1
  ),
  rownames = FALSE
)

bscols(widths = c(6, 6), p, tbl)

plotdata <- (plotdata[plotdata$X2<6 & plotdata$X1 < 10,])
