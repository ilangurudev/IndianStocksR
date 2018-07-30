README
================
Gurudev Ilangovan
2018-07-29

[![Travis-CI Build
Status](https://travis-ci.org/ilangurudev/IndianStocksR.svg?branch=master)](https://travis-ci.org/ilangurudev/IndianStocksR)

# Introduction

The `IndianStocksR` package is used to download the end of day data of
all stocks in the two primary Indian stock markets,
[NSE](http://nseindia.com/) and [BSE](https://www.bseindia.com/). The
end of data data is provided free by the two stock exchanges from their
websites and consists of information like the open, high, low, close
among others for each script that’s traded in them.

The data can be accessed from their websites based on the date formatted
in a certain way. The R-Bloggers
[article](https://www.r-bloggers.com/extracting-eod-data-from-nse/) was
the source of inspiration for the package. However, the package
modularizes the code, tweaks a lot of things and creates a much more
accessible API that’s more powerful in the sense that it abstracts away
the complexity from the user.

It is advised to create a folder and set the working directory to that
folder before we start work. Even better, if you’re working from R
studio is to create an R project for downloading the data and working on
your analysis.

The package is currently getting submitted to CRAN after which a simple
`install.packages("IndianStocksR")` will get it installed. But for now,
it is available on github.

    install.packages("devtools")
    devtools::install_github("ilangurudev/IndianStocksR")

After installation, we load the package. The package basically creates
data frames and hence plays along well with the concepts of tidy data
and the `tidyverse`. So it is highly encouraged to load that package as
well

``` r
library(IndianStocksR)
library(tidyverse)
```

<br>

# Main Functions

## `download_stocks`

The workhorse of the package is the function `download_stocks`. However,
you will rarely have to use it. It still pays to understand the
parameters as it is the basis of the other functions that you will
probably
use.

``` r
download_stocks(date = "2018-07-20", exchange = c("nse", "bse"), dest_path = "./data", quiet = FALSE)
```

    ## Downloading from 'nse' as exchange not clearly specified.

    ## Dowloaded stocks data from NSE on 20 JUL 2018

  - The `date` parameter can be a date object (and defaults to today).
    It can also be a string (yyyy-mm-dd) or a number that can be parsed
    as a date by `lubridate::as_date()`. For instance, `"2018-05-21"` is
    a valid date.
  - The `exchange` can either be “nse” or “bse”.
  - The `dest_path` specifies where you want the data files to get
    downloaded. It defaults to the data folder in the current working
    directory (which it will create if not found). This is why it is
    advisable to work in a project. This keeps all the data files of a
    project organized. If the path you specify is not found, an error is
    thrown.
  - The `quiet` parameter controls whether you want the download status
    messages or not.

The main purpose of this function is to download data from the specified
exchange on the mentioned date. If data is not available for the date
you specified, you will get an error.

<br>

## `download_stocks_period`

The function you’ll probably have to use first is the
`download_stocks_period`

``` r
df_period <- 
  download_stocks_period(start = "2018-07-21",
                         end = "2018-07-26",
                         exchange = c("both", "nse", "bse"),
                         dest_path = "./data",
                         compile = TRUE,
                         delete_component_files = TRUE,
                         quiet = FALSE)
```

  - `start` and `end`: The download stocks period downloads data for all
    the dates in the date range specified by `start` and `end`. `start`
    defaults to today - 8 days and `end` defaults to today. If today is
    2018-07-30, then end takes that value and start takes the value
    2018-07-22. However, it makes sense to make start today - 365 or
    specify the actual date from when you want the data. You could
    change the `end` value too if you want data for a specific date
    range. The `start` and `end` values follow the same rules as the
    `date` parameter in `download_stocks`
  - The `exchange`function’s behavior is pretty straightforward.
    Downloads data for the date range from NSE if “nse” or BSE from
    “bse” or both NSE and BSE if “both”. Defaults to “both”
  - The `dest_path` does the same job as it does in `download_stocks`
  - The `compile` parameter compiles all the downloaded files into one
    file (if exchange is “both”, one compiled file for “nse”, one for
    “bse” and one combined). This option is by default on as compiled
    files are much more tractable for analysis.
  - The `delete_component_files` deletes everything apart from the
    compiled files. This keeps the work space clean and more efficient
    for updating.
  - The `quiet` does the same job as it does in `download_stocks`

Let’s take a look at
`df_period`.

    df_period %>% slice(1:200)

<div style="border: 1px solid #ddd; padding: 5px; overflow-y: scroll; height:500px; overflow-x: scroll; width:1000px; ">

<table class="table table-striped table-hover table-responsive" style="width: auto !important; ">

<thead>

<tr>

<th style="text-align:left;">

exchange

</th>

<th style="text-align:left;">

date

</th>

<th style="text-align:left;">

symbol

</th>

<th style="text-align:left;">

isin

</th>

<th style="text-align:right;">

open

</th>

<th style="text-align:right;">

high

</th>

<th style="text-align:right;">

low

</th>

<th style="text-align:right;">

close

</th>

<th style="text-align:right;">

volume

</th>

<th style="text-align:left;">

series

</th>

<th style="text-align:right;">

last

</th>

<th style="text-align:right;">

prevclose

</th>

<th style="text-align:right;">

tottrdval

</th>

<th style="text-align:left;">

timestamp

</th>

<th style="text-align:right;">

totaltrades

</th>

<th style="text-align:left;">

sc\_group

</th>

<th style="text-align:right;">

no\_trades

</th>

<th style="text-align:right;">

net\_turnov

</th>

<th style="text-align:left;">

tdcloindi

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-20

</td>

<td style="text-align:left;">

20MICRONS

</td>

<td style="text-align:left;">

INE144J01027

</td>

<td style="text-align:right;">

34.90

</td>

<td style="text-align:right;">

35.20

</td>

<td style="text-align:right;">

33.90

</td>

<td style="text-align:right;">

34.40

</td>

<td style="text-align:right;">

42383

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

34.75

</td>

<td style="text-align:right;">

34.60

</td>

<td style="text-align:right;">

1456395.4

</td>

<td style="text-align:left;">

20-JUL-2018

</td>

<td style="text-align:right;">

607

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-20

</td>

<td style="text-align:left;">

21STCENMGM

</td>

<td style="text-align:left;">

INE253B01015

</td>

<td style="text-align:right;">

34.90

</td>

<td style="text-align:right;">

34.90

</td>

<td style="text-align:right;">

34.90

</td>

<td style="text-align:right;">

34.90

</td>

<td style="text-align:right;">

1202

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

34.90

</td>

<td style="text-align:right;">

34.25

</td>

<td style="text-align:right;">

41949.8

</td>

<td style="text-align:left;">

20-JUL-2018

</td>

<td style="text-align:right;">

4

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-20

</td>

<td style="text-align:left;">

3IINFOTECH

</td>

<td style="text-align:left;">

INE748C01020

</td>

<td style="text-align:right;">

3.55

</td>

<td style="text-align:right;">

3.70

</td>

<td style="text-align:right;">

3.50

</td>

<td style="text-align:right;">

3.50

</td>

<td style="text-align:right;">

2998992

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

3.50

</td>

<td style="text-align:right;">

3.60

</td>

<td style="text-align:right;">

10717093.0

</td>

<td style="text-align:left;">

20-JUL-2018

</td>

<td style="text-align:right;">

1137

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-20

</td>

<td style="text-align:left;">

3MINDIA

</td>

<td style="text-align:left;">

INE470A01017

</td>

<td style="text-align:right;">

21541.00

</td>

<td style="text-align:right;">

23490.00

</td>

<td style="text-align:right;">

21318.55

</td>

<td style="text-align:right;">

23338.75

</td>

<td style="text-align:right;">

9813

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

23100.00

</td>

<td style="text-align:right;">

21722.15

</td>

<td style="text-align:right;">

222218068.8

</td>

<td style="text-align:left;">

20-JUL-2018

</td>

<td style="text-align:right;">

4330

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-20

</td>

<td style="text-align:left;">

3PLAND

</td>

<td style="text-align:left;">

INE105C01023

</td>

<td style="text-align:right;">

15.00

</td>

<td style="text-align:right;">

15.00

</td>

<td style="text-align:right;">

12.65

</td>

<td style="text-align:right;">

13.15

</td>

<td style="text-align:right;">

2517

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

13.10

</td>

<td style="text-align:right;">

13.45

</td>

<td style="text-align:right;">

33735.6

</td>

<td style="text-align:left;">

20-JUL-2018

</td>

<td style="text-align:right;">

28

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-20

</td>

<td style="text-align:left;">

5PAISA

</td>

<td style="text-align:left;">

INE618L01018

</td>

<td style="text-align:right;">

294.75

</td>

<td style="text-align:right;">

304.95

</td>

<td style="text-align:right;">

294.75

</td>

<td style="text-align:right;">

300.85

</td>

<td style="text-align:right;">

2925

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

302.00

</td>

<td style="text-align:right;">

304.05

</td>

<td style="text-align:right;">

875384.8

</td>

<td style="text-align:left;">

20-JUL-2018

</td>

<td style="text-align:right;">

241

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-20

</td>

<td style="text-align:left;">

63MOONS

</td>

<td style="text-align:left;">

INE111B01023

</td>

<td style="text-align:right;">

65.25

</td>

<td style="text-align:right;">

66.80

</td>

<td style="text-align:right;">

63.10

</td>

<td style="text-align:right;">

65.55

</td>

<td style="text-align:right;">

216988

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

65.20

</td>

<td style="text-align:right;">

65.20

</td>

<td style="text-align:right;">

14102114.2

</td>

<td style="text-align:left;">

20-JUL-2018

</td>

<td style="text-align:right;">

2403

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-20

</td>

<td style="text-align:left;">

8KMILES

</td>

<td style="text-align:left;">

INE650K01021

</td>

<td style="text-align:right;">

335.00

</td>

<td style="text-align:right;">

339.00

</td>

<td style="text-align:right;">

307.50

</td>

<td style="text-align:right;">

307.50

</td>

<td style="text-align:right;">

1422247

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

307.50

</td>

<td style="text-align:right;">

341.65

</td>

<td style="text-align:right;">

444749983.2

</td>

<td style="text-align:left;">

20-JUL-2018

</td>

<td style="text-align:right;">

21142

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-20

</td>

<td style="text-align:left;">

A2ZINFRA

</td>

<td style="text-align:left;">

INE619I01012

</td>

<td style="text-align:right;">

19.65

</td>

<td style="text-align:right;">

20.10

</td>

<td style="text-align:right;">

19.30

</td>

<td style="text-align:right;">

19.80

</td>

<td style="text-align:right;">

168417

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

19.70

</td>

<td style="text-align:right;">

19.80

</td>

<td style="text-align:right;">

3304622.9

</td>

<td style="text-align:left;">

20-JUL-2018

</td>

<td style="text-align:right;">

740

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-20

</td>

<td style="text-align:left;">

AARTIDRUGS

</td>

<td style="text-align:left;">

INE767A01016

</td>

<td style="text-align:right;">

520.70

</td>

<td style="text-align:right;">

527.00

</td>

<td style="text-align:right;">

520.00

</td>

<td style="text-align:right;">

521.75

</td>

<td style="text-align:right;">

5263

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

520.00

</td>

<td style="text-align:right;">

520.95

</td>

<td style="text-align:right;">

2757494.0

</td>

<td style="text-align:left;">

20-JUL-2018

</td>

<td style="text-align:right;">

538

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-20

</td>

<td style="text-align:left;">

AARTIIND

</td>

<td style="text-align:left;">

INE769A01020

</td>

<td style="text-align:right;">

1197.15

</td>

<td style="text-align:right;">

1229.80

</td>

<td style="text-align:right;">

1197.15

</td>

<td style="text-align:right;">

1215.45

</td>

<td style="text-align:right;">

7544

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

1211.00

</td>

<td style="text-align:right;">

1204.40

</td>

<td style="text-align:right;">

9197825.1

</td>

<td style="text-align:left;">

20-JUL-2018

</td>

<td style="text-align:right;">

1295

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-20

</td>

<td style="text-align:left;">

AARVEEDEN

</td>

<td style="text-align:left;">

INE273D01019

</td>

<td style="text-align:right;">

29.60

</td>

<td style="text-align:right;">

30.40

</td>

<td style="text-align:right;">

28.80

</td>

<td style="text-align:right;">

29.10

</td>

<td style="text-align:right;">

8583

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

29.10

</td>

<td style="text-align:right;">

29.55

</td>

<td style="text-align:right;">

250922.4

</td>

<td style="text-align:left;">

20-JUL-2018

</td>

<td style="text-align:right;">

63

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-20

</td>

<td style="text-align:left;">

ABAN

</td>

<td style="text-align:left;">

INE421A01028

</td>

<td style="text-align:right;">

101.80

</td>

<td style="text-align:right;">

103.95

</td>

<td style="text-align:right;">

100.15

</td>

<td style="text-align:right;">

101.90

</td>

<td style="text-align:right;">

462821

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

102.30

</td>

<td style="text-align:right;">

102.20

</td>

<td style="text-align:right;">

47025017.7

</td>

<td style="text-align:left;">

20-JUL-2018

</td>

<td style="text-align:right;">

5859

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-20

</td>

<td style="text-align:left;">

ABB

</td>

<td style="text-align:left;">

INE117A01022

</td>

<td style="text-align:right;">

1164.90

</td>

<td style="text-align:right;">

1179.95

</td>

<td style="text-align:right;">

1129.00

</td>

<td style="text-align:right;">

1134.95

</td>

<td style="text-align:right;">

186787

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

1132.00

</td>

<td style="text-align:right;">

1157.60

</td>

<td style="text-align:right;">

215143192.6

</td>

<td style="text-align:left;">

20-JUL-2018

</td>

<td style="text-align:right;">

14947

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-20

</td>

<td style="text-align:left;">

ABBOTINDIA

</td>

<td style="text-align:left;">

INE358A01014

</td>

<td style="text-align:right;">

7286.00

</td>

<td style="text-align:right;">

7348.75

</td>

<td style="text-align:right;">

7193.60

</td>

<td style="text-align:right;">

7311.95

</td>

<td style="text-align:right;">

3185

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

7325.00

</td>

<td style="text-align:right;">

7266.20

</td>

<td style="text-align:right;">

23211751.7

</td>

<td style="text-align:left;">

20-JUL-2018

</td>

<td style="text-align:right;">

813

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

</tbody>

</table>

</div>

The function returns the compiled files apart from writing them out as a
csv.

<br>

## `update_stocks`

Once you have the `download_stocks_period` run, you can update the
database later by running the `update_stocks`

``` r
df_updated <- 
  update_stocks(data_path = "./data",
                till = lubridate::today(),
                exchange = c("both", "nse", "bse"),
                compile = TRUE,
                delete_component_files = TRUE)
```

Most of this parameters have been discussed before. This function scans
all the files in the directory and finds out the date till which there
is data and downloads data from the day after till the date mentioned by
`till`. If there are no files inside the specified folder, it downloads
data from today - 8 till the date mentioned by `till`. You rarely have
to tweak the `till` function. It’s primarily used to update till the
current day.

Let’s take a look at
`df_updated`.

    df_updated %>% slice(1:200)

<div style="border: 1px solid #ddd; padding: 5px; overflow-y: scroll; height:500px; overflow-x: scroll; width:1000px; ">

<table class="table table-striped table-hover table-responsive" style="width: auto !important; ">

<thead>

<tr>

<th style="text-align:left;">

exchange

</th>

<th style="text-align:left;">

date

</th>

<th style="text-align:left;">

symbol

</th>

<th style="text-align:left;">

isin

</th>

<th style="text-align:right;">

open

</th>

<th style="text-align:right;">

high

</th>

<th style="text-align:right;">

low

</th>

<th style="text-align:right;">

close

</th>

<th style="text-align:right;">

volume

</th>

<th style="text-align:left;">

series

</th>

<th style="text-align:right;">

last

</th>

<th style="text-align:right;">

prevclose

</th>

<th style="text-align:right;">

tottrdval

</th>

<th style="text-align:left;">

timestamp

</th>

<th style="text-align:right;">

totaltrades

</th>

<th style="text-align:left;">

sc\_group

</th>

<th style="text-align:right;">

no\_trades

</th>

<th style="text-align:right;">

net\_turnov

</th>

<th style="text-align:left;">

tdcloindi

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-27

</td>

<td style="text-align:left;">

20MICRONS

</td>

<td style="text-align:left;">

INE144J01027

</td>

<td style="text-align:right;">

39.00

</td>

<td style="text-align:right;">

40.30

</td>

<td style="text-align:right;">

37.50

</td>

<td style="text-align:right;">

39.90

</td>

<td style="text-align:right;">

92698

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

39.85

</td>

<td style="text-align:right;">

38.85

</td>

<td style="text-align:right;">

3658998.65

</td>

<td style="text-align:left;">

27-JUL-2018

</td>

<td style="text-align:right;">

649

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-27

</td>

<td style="text-align:left;">

21STCENMGM

</td>

<td style="text-align:left;">

INE253B01015

</td>

<td style="text-align:right;">

37.10

</td>

<td style="text-align:right;">

37.10

</td>

<td style="text-align:right;">

36.50

</td>

<td style="text-align:right;">

37.10

</td>

<td style="text-align:right;">

542

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

37.10

</td>

<td style="text-align:right;">

36.40

</td>

<td style="text-align:right;">

20101.10

</td>

<td style="text-align:left;">

27-JUL-2018

</td>

<td style="text-align:right;">

10

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-27

</td>

<td style="text-align:left;">

3IINFOTECH

</td>

<td style="text-align:left;">

INE748C01020

</td>

<td style="text-align:right;">

3.60

</td>

<td style="text-align:right;">

3.60

</td>

<td style="text-align:right;">

3.50

</td>

<td style="text-align:right;">

3.55

</td>

<td style="text-align:right;">

2067721

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

3.55

</td>

<td style="text-align:right;">

3.55

</td>

<td style="text-align:right;">

7328844.40

</td>

<td style="text-align:left;">

27-JUL-2018

</td>

<td style="text-align:right;">

2013

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-27

</td>

<td style="text-align:left;">

3MINDIA

</td>

<td style="text-align:left;">

INE470A01017

</td>

<td style="text-align:right;">

23610.00

</td>

<td style="text-align:right;">

23749.95

</td>

<td style="text-align:right;">

23400.00

</td>

<td style="text-align:right;">

23609.80

</td>

<td style="text-align:right;">

924

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

23500.00

</td>

<td style="text-align:right;">

23676.55

</td>

<td style="text-align:right;">

21850559.30

</td>

<td style="text-align:left;">

27-JUL-2018

</td>

<td style="text-align:right;">

504

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-27

</td>

<td style="text-align:left;">

3PLAND

</td>

<td style="text-align:left;">

INE105C01023

</td>

<td style="text-align:right;">

13.50

</td>

<td style="text-align:right;">

13.95

</td>

<td style="text-align:right;">

11.55

</td>

<td style="text-align:right;">

12.15

</td>

<td style="text-align:right;">

1887

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

13.90

</td>

<td style="text-align:right;">

13.85

</td>

<td style="text-align:right;">

24549.25

</td>

<td style="text-align:left;">

27-JUL-2018

</td>

<td style="text-align:right;">

57

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-27

</td>

<td style="text-align:left;">

5PAISA

</td>

<td style="text-align:left;">

INE618L01018

</td>

<td style="text-align:right;">

346.00

</td>

<td style="text-align:right;">

352.85

</td>

<td style="text-align:right;">

337.00

</td>

<td style="text-align:right;">

344.55

</td>

<td style="text-align:right;">

3191

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

341.00

</td>

<td style="text-align:right;">

345.50

</td>

<td style="text-align:right;">

1095565.05

</td>

<td style="text-align:left;">

27-JUL-2018

</td>

<td style="text-align:right;">

301

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-27

</td>

<td style="text-align:left;">

63MOONS

</td>

<td style="text-align:left;">

INE111B01023

</td>

<td style="text-align:right;">

70.00

</td>

<td style="text-align:right;">

71.00

</td>

<td style="text-align:right;">

69.50

</td>

<td style="text-align:right;">

69.80

</td>

<td style="text-align:right;">

93732

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

69.60

</td>

<td style="text-align:right;">

69.40

</td>

<td style="text-align:right;">

6571384.30

</td>

<td style="text-align:left;">

27-JUL-2018

</td>

<td style="text-align:right;">

1215

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-27

</td>

<td style="text-align:left;">

8KMILES

</td>

<td style="text-align:left;">

INE650K01021

</td>

<td style="text-align:right;">

260.85

</td>

<td style="text-align:right;">

260.85

</td>

<td style="text-align:right;">

260.85

</td>

<td style="text-align:right;">

260.85

</td>

<td style="text-align:right;">

25045

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

260.85

</td>

<td style="text-align:right;">

248.45

</td>

<td style="text-align:right;">

6532988.25

</td>

<td style="text-align:left;">

27-JUL-2018

</td>

<td style="text-align:right;">

353

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-27

</td>

<td style="text-align:left;">

A2ZINFRA

</td>

<td style="text-align:left;">

INE619I01012

</td>

<td style="text-align:right;">

21.40

</td>

<td style="text-align:right;">

25.50

</td>

<td style="text-align:right;">

21.30

</td>

<td style="text-align:right;">

24.65

</td>

<td style="text-align:right;">

2830527

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

24.25

</td>

<td style="text-align:right;">

21.25

</td>

<td style="text-align:right;">

68796473.80

</td>

<td style="text-align:left;">

27-JUL-2018

</td>

<td style="text-align:right;">

4056

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-27

</td>

<td style="text-align:left;">

AAKASH

</td>

<td style="text-align:left;">

INE087Z01016

</td>

<td style="text-align:right;">

34.50

</td>

<td style="text-align:right;">

34.50

</td>

<td style="text-align:right;">

34.50

</td>

<td style="text-align:right;">

34.50

</td>

<td style="text-align:right;">

2000

</td>

<td style="text-align:left;">

SM

</td>

<td style="text-align:right;">

34.50

</td>

<td style="text-align:right;">

35.00

</td>

<td style="text-align:right;">

69000.00

</td>

<td style="text-align:left;">

27-JUL-2018

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-27

</td>

<td style="text-align:left;">

AARTIDRUGS

</td>

<td style="text-align:left;">

INE767A01016

</td>

<td style="text-align:right;">

548.60

</td>

<td style="text-align:right;">

567.00

</td>

<td style="text-align:right;">

545.95

</td>

<td style="text-align:right;">

552.70

</td>

<td style="text-align:right;">

12211

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

551.10

</td>

<td style="text-align:right;">

545.30

</td>

<td style="text-align:right;">

6823408.25

</td>

<td style="text-align:left;">

27-JUL-2018

</td>

<td style="text-align:right;">

920

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-27

</td>

<td style="text-align:left;">

AARTIIND

</td>

<td style="text-align:left;">

INE769A01020

</td>

<td style="text-align:right;">

1264.55

</td>

<td style="text-align:right;">

1274.00

</td>

<td style="text-align:right;">

1245.00

</td>

<td style="text-align:right;">

1252.40

</td>

<td style="text-align:right;">

14181

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

1258.70

</td>

<td style="text-align:right;">

1260.25

</td>

<td style="text-align:right;">

17933400.20

</td>

<td style="text-align:left;">

27-JUL-2018

</td>

<td style="text-align:right;">

1765

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-27

</td>

<td style="text-align:left;">

AARVEEDEN

</td>

<td style="text-align:left;">

INE273D01019

</td>

<td style="text-align:right;">

32.00

</td>

<td style="text-align:right;">

32.75

</td>

<td style="text-align:right;">

31.35

</td>

<td style="text-align:right;">

32.40

</td>

<td style="text-align:right;">

16656

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

32.25

</td>

<td style="text-align:right;">

31.50

</td>

<td style="text-align:right;">

535642.45

</td>

<td style="text-align:left;">

27-JUL-2018

</td>

<td style="text-align:right;">

93

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-27

</td>

<td style="text-align:left;">

ABAN

</td>

<td style="text-align:left;">

INE421A01028

</td>

<td style="text-align:right;">

106.95

</td>

<td style="text-align:right;">

110.80

</td>

<td style="text-align:right;">

105.75

</td>

<td style="text-align:right;">

108.35

</td>

<td style="text-align:right;">

662013

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

108.00

</td>

<td style="text-align:right;">

105.65

</td>

<td style="text-align:right;">

72033538.90

</td>

<td style="text-align:left;">

27-JUL-2018

</td>

<td style="text-align:right;">

7728

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

nse

</td>

<td style="text-align:left;">

2018-07-27

</td>

<td style="text-align:left;">

ABB

</td>

<td style="text-align:left;">

INE117A01022

</td>

<td style="text-align:right;">

1188.00

</td>

<td style="text-align:right;">

1194.00

</td>

<td style="text-align:right;">

1175.00

</td>

<td style="text-align:right;">

1188.40

</td>

<td style="text-align:right;">

33749

</td>

<td style="text-align:left;">

EQ

</td>

<td style="text-align:right;">

1185.00

</td>

<td style="text-align:right;">

1175.85

</td>

<td style="text-align:right;">

40011149.80

</td>

<td style="text-align:left;">

27-JUL-2018

</td>

<td style="text-align:right;">

2781

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:left;">

NA

</td>

</tr>

</tbody>

</table>

</div>

<br>

## A note on defaults

Except the date parameters, one rarely has to tweak the defaults. The
defaults are designed to work optimally.

# Bugs, comments, suggestions and feature requests

This is just an initial version of the package and I expect to see a few
bugs. I’d be very happy if you create github issues if you run into
anything. Suggestions and feature requests welcome. Feel free to comment
what you think of the package.

Thanks for reading\! Cheers\!
