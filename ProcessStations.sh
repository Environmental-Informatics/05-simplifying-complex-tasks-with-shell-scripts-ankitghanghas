#!/bin/bash
# Processes data as per Lab Assignment 5 
# Takes input data from a folder and seperates the file with station altitude greater than 200 to a new directory named HigherElevation.
# generates three figures of the data in the format .ps .epsi and .tif, where all the stations are plotted as black and stations with elevation greater than 200 as red circles
# By Ankit Ghanghas

if [ ! -d HigherElevation ] # this if loop checks if the directory 'HigherElevation' exists in the present working directory, if not then it creates a directory name Higher Elevation
then
	mkdir HigherElevation
fi

for file in StationData/*.txt # this for loop loops over all the .txt files in StationData/ directory and copies files with station elevation greater than 200 to the HigherElevation directory
do
	a=$(grep "# Station Altitude:" $file | cut -c 21-30) # extracts the elevation data from the file (looks for line which contatins 'Station Altitude' and cuts the values between columns 21-30 in that line
	if (( $(awk 'BEGIN {print ("'$a'" >= 200.0)}') )) # does numerical comparison of value of variable a with 200 and if a>200 then copies that file to the specified directory
	then
		cp $file ./HigherElevation/$(basename $file)
	fi
done

awk '/Longitude/ {print -1 * $NF}' StationData/Station_*.txt > Long.list # NF gives the number of field in the line containing Longitude and $ picks up last field and multiplies it by -1 and stores it to Long.list
awk '/Latitude/ {print 1 * $NF}' StationData/Station_*.txt > Lat.list
paste Long.list Lat.list > AllStation.xy
rm *.list # removes all the files with extension .list in the directory
awk '/Longitude/ {print -1 * $NF}' HigherElevation/Station_*.txt > Long.list
awk '/Latitude/ {print 1 * $NF}' HigherElevation/Station_*.txt > Lat.list
paste Long.list Lat.list > HEStation.xy
rm *.list

module load gmt

gmt set PROJ_LENGTH_UNIT = inch # sets project length unit to inch
gmt set PS_MEDIA = letter # sets default size to letter
gmt pscoast -JU16/4i -R-93/-86/36/43 -Dh -B2f0.5 -Cl/Blue -Ia/blue -Na/orange -P -K -V > SoilMoistureStations.ps # imports high defination coast and physical boundaries to the map and specifies the co-ordinate system and extent, fills lakes with blue and sets rivers to blue and physical boundaries to orange colour and stores this info in SoilMoistureStations.ps
gmt psxy AllStation.xy -J -R -Sc0.15 -Gblack -K -O -V >> SoilMoistureStations.ps # adds points in AllStations.xy as black circle dots of size 0.15
gmt psxy HEStation.xy -J -R -Sc0.05 -Gred -O -V >> SoilMoistureStations.ps # add points in HEStations.xy as red circle dots of size 0.05
gv SoilMoistureStations.ps & # displays SoilMoistureStations.ps

ps2epsi SoilMoistureStations.ps SoilMoistureStations.epsi # converts the .ps file to .epsi
gv SoilMoistureStations.epsi &

convert SoilMoistureStations.epsi -density 150 SoilMoistureStations.tif #converts the .epsi image to .tif of pixel density 150
