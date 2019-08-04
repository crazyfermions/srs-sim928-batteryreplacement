# README

## About

This is a guide on how to replace the batteries inside a [Stanford Research Systems SIM928 Rechargeable Isolated Voltage Source](https://www.thinksrs.com/products/sim928.html). The SIM928 is a battery driven voltage source which has two groups of rechargable 9V batteries where one group powers the voltage source while the other is being recharged. After one group is depleted, the device switches to the other group and charges the depleted one. Since the lifetimes of the batteries is quite limited, the batteries have to be exchanged quite often.

## Notes

This guide was initially written some time ago (2014) and has not been maintained at all, so some information might be outdated. I used this method several times in the lab with no downsides whatsoever - however of course I cannot guarantee that you have unwanted side effects; using the method described here is on your own risk. Especially if you use a different battery model, manufacturer, etc. you might want to monitor the device first on a dummy application. If you find any outdated information or other issues, please make a pull request on [github](https://github.com/crazyfermions/srs-sim928-batteryreplacement). There are also some parts not understood about the hardware - if you find new information, please share and improve the guide.

## Contents

The [basic guide](doc.rst) is just a single document. It is recommended to be read with a rst renderer, since it contains some images, for example directly on github. There is also the possibility to make an html document with [pandoc](https://pandoc.org/) with `make`.
