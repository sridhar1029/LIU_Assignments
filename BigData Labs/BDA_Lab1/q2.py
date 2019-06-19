#!/usr/bin/env python2
# -*- coding: utf-8 -*-

#Sridhar Adhikarla

from pyspark import SparkContext

iFile = 'data/temperature-readings.csv'
oFile = 'outputs/out2_a'
oFile2 = 'outputs/out2_b'
fromYear = 1950
toYear = 2014
target_temp = 10

sc = SparkContext(appName="Lab1_Q2_SparkJob")

lines = sc.textFile(iFile)
lines = lines.map(lambda a: a.split(";"))
observations = lines.filter(lambda observation:(int(observation[1][:4]) >= fromYear and int(observation[1][:4]) <= toYear)).cache()

#Q2a. Year-month, number
temperatures = observations.map(lambda observation:
                                    (observation[1][:7], (float(observation[3]), 1))) \
                               .filter(lambda (month, (temp, count)): temp > target_temp)

reading_counts = temperatures.reduceByKey(lambda (temp1, count1), (temp2, count2):
                                              (temp1, count1 + count2)) \
                                 .map(lambda (month, (temp, count)):(month, count))

reading_counts.repartition(1).saveAsTextFile(oFile)

#Q2b. Year-month, distinct number
station_temperatures = observations.map(lambda observation:
                                            (observation[1][:7],
                                             (observation[0], float(observation[3])))) \
                                       .filter(lambda (month, (station, temp)): temp > target_temp)

year_station = station_temperatures.map(lambda (month, (station, temp)): (month, (station, 1))).distinct()

reading_counts = year_station.reduceByKey(lambda (station1, count1), (station2, count2):
                                              (station1, count1 + count2)) \
                                 .map(lambda (month, (station, count)): (month, count))

reading_counts.repartition(1).saveAsTextFile(oFile2)
