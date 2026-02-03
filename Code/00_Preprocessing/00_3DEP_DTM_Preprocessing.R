library(raster)
library(terra)
library(sf)
library(lidR)
library(ggplot2)

setwd('../../')
git.fp = getwd()
data.fp = paste(git.fp, 'Data', '3DEP_DTM', sep = '/')
setwd('../../')
laz.fp = paste(getwd(), 'Data', '3DEP_Lidar_WKG', sep = '/')

laz.files = list.files(laz.fp, pattern = '.laz', full.names = TRUE)

wkg.laz.1 = readLAS(laz.files[1])
wkg.laz.2 = readLAS(laz.files[2])
wkg.laz.3 = readLAS(laz.files[3])
wkg.laz.4 = readLAS(laz.files[4])

ground.points.1 = filter_poi(wkg.laz.1, Classification == 2)
ground.points.2 = filter_poi(wkg.laz.2, Classification == 2)
ground.points.3 = filter_poi(wkg.laz.3, Classification == 2)
ground.points.4 = filter_poi(wkg.laz.4, Classification == 2)

dtm.1 = raster(rasterize_terrain(ground.points.1, res = 1, algorithm = tin()))
dtm.2 = raster(rasterize_terrain(ground.points.2, res = 1, algorithm = tin()))
dtm.3 = raster(rasterize_terrain(ground.points.3, res = 1, algorithm = tin()))
dtm.4 = raster(rasterize_terrain(ground.points.4, res = 1, algorithm = tin()))

wkg.bbox = spTransform(as(st_zm(st_read(paste(data.fp, 'wkg_bbox.kml', sep = '/'))), 'Spatial'), CRSobj = wkg.laz.1@crs$wkt)

wkg.dtm = crop(round((do.call(mosaic, c(c(dtm.1, dtm.2, dtm.3, dtm.4), fun = mean, na.rm = TRUE))), 2), wkg.bbox)

writeRaster(wkg.dtm,
            filename = paste(data.fp, 'WKG_DTM_meters.tif', sep = '/'),
            format = 'GTiff',
            overwrite = TRUE)